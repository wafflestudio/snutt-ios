# 강의 일기장 (Lecture Diary) 기능 마이그레이션 스펙

> **참고**: API 통신 관련 코드(DTO, Router)는 OpenAPI Generator로 자동 생성되므로 이 문서에서는 UI/UX와 화면 동작에 집중합니다.

## 개요

PR #391에서 구현된 강의 일기장 기능의 UI/UX 스펙 문서입니다.

**PR 정보:**
- PR 번호: #391
- 브랜치: `peng-u-0807/lecture-diary`
- 상태: WIP (Work In Progress)
- 작성자: peng-u-0807

## 1. 기능 설명

강의 일기장은 사용자가 수강한 강의에 대한 의견과 경험을 기록하는 기능입니다.

### 주요 기능
1. **강의일기 작성**: 특정 강의에 대한 설문 답변 + 추가 코멘트 작성
2. **강의일기 목록 조회**: 학기별로 작성한 강의일기 확인
3. **강의일기 삭제**: 작성한 강의일기 삭제

### 진입점
- **설정 화면**: "강의 일기장" 메뉴 아이템 추가됨
  ```swift
  SettingsLinkItem(title: "강의 일기장") {
      LectureDiaryListView(viewModel: .init(container: viewModel.container))
  }
  ```

## 2. 화면 플로우

```
Settings
  ↓
LectureDiaryListView (목록)
  ├─ Empty State → "강의일기 작성하기" 버튼
  │   ↓
  │   EditLectureDiaryScene (작성)
  │     ↓
  │     LectureDiaryConfirmView (완료)
  │
  └─ Filled State
      ├─ 학기별 탭
      ├─ 일기 카드 (확장/축소)
      └─ 삭제 기능
```

## 3. 화면 상세 스펙

### 3.1 LectureDiaryListView - 강의일기 목록 화면

#### 3.1.1 네비게이션
- **Title**: "강의 일기장"
- **Display Mode**: `.inline`

#### 3.1.2 Empty State (일기가 없을 때)

**레이아웃:**
```
┌─────────────────────────────────┐
│                                 │
│         [warning.cat.red]       │ ← 이미지
│                                 │
│    강의일기장이 비어있어요.         │ ← semibold 15pt
│                                 │
│  매주 마지막 수업날,                │ ← regular 13pt
│  푸시알림을 통해 강의일기를          │   line height 145%
│  작성해보세요!                     │
│                                 │
│   ┌──────────────────────┐     │
│   │ 강의일기 작성하기   →  │     │ ← Capsule button
│   └──────────────────────┘     │
│                                 │
└─────────────────────────────────┘
```

**색상:**
- 설명 텍스트: Dark - gray30, Light - primary.opacity(0.5)
- 버튼 border: Dark - gray30.opacity(0.4), Light - border

**동작:**
1. "강의일기 작성하기" 버튼 탭
2. 현재/다음 학기의 대표 시간표에서 lectureId 있는 첫 번째 강의 조회
3. 강의가 없으면 "강의일기장을 작성할 수 있는 강의가 없습니다." 알림
4. 강의가 있으면 `EditLectureDiaryScene` fullScreenCover로 표시

#### 3.1.3 Filled State (일기가 있을 때)

**레이아웃:**
```
┌─────────────────────────────────┐
│ ┌──────────────────────────┐   │
│ │ [25-1] [25-2] [25-여름]   │   │ ← Horizontal scroll
│ └──────────────────────────┘   │
│                                 │
│ 2025.11.29   금                 │ ← Header
│ 시각디자인기초, 배구         ⌄   │ ← 확장 버튼
│                                 │
│ ┌─────────────────────────┐   │
│ │ 시각디자인기초        [🗑]│   │ ← 카드
│ │                           │   │
│ │ 수강신청    널널해요         │   │
│ │ 드랍여부    모르겠어요       │   │
│ │ 수업 첫인상  두려워요        │   │
│ │ 남기고      오티 했어용...   │   │
│ │ 싶은 말                    │   │
│ └─────────────────────────┘   │
│                                 │
│ ┌─────────────────────────┐   │
│ │ 배구                  [🗑]│   │
│ │ ...                       │   │
│ └─────────────────────────┘   │
└─────────────────────────────────┘
```

**학기 칩 (SemesterChip):**
- Format: "YY-학기" (예: "25-1", "25-2", "25-여름", "25-겨울")
- 선택됨: Dark - 배경 darkMint1, Light - 배경 cyan
- 선택 안 됨: Dark - 배경 neutral5, Light - 배경 neutral98
- Padding: horizontal 20, vertical 20 (상단), 12 (하단)
- Spacing: 8pt

**일기 카드 (ExpandableDiarySummaryCell):**
- Padding: top 16, bottom 16~32 (확장 여부), horizontal 20
- 배경: Dark - groupBackground, Light - neutral98
- Corner radius: 4
- 삭제 알림: "'{강의명}' 강의일기를 삭제하시겠습니까?"

**동작:**
- 학기 칩 탭: 해당 학기 일기만 필터링 (구현 완료 여부 불명확)
- Header 탭: 카드 확장/축소 (화살표 90도 회전)
- 휴지통 아이콘 탭: 삭제 확인 알림 → 삭제 → 빈 학기 자동 제거

---

### 3.2 EditLectureDiaryScene - 강의일기 작성 화면

#### 3.2.1 Header (고정)

**레이아웃:**
```
┌──────────────────────────────────┐
│ 오늘 수강한 '{강의명}'에 대한        │ ← bold 17pt
│ 의견을 남겨보세요.                 │   line height 145%
│                                  │
│ 더보기 > 강의일기장에서 확인할 수    │ ← regular 14pt
│ 있어요.                      [X] │
└──────────────────────────────────┘
```

**스타일:**
- Padding: top 44, horizontal 24, bottom 24
- 배경: Dark - groupBackground, Light - white
- 하단 Divider: border 색상
- Shadow: black.opacity(0.02), radius 12, y 6

**동작:**
- X 버튼 탭: "강의일기 작성을 중단하시겠습니까?" 알림
  - "확인" (destructive): dismiss
  - "취소": 계속 작성

#### 3.2.2 Step 1: 수업 유형 선택

**레이아웃:**
```
┌──────────────────────────────────┐
│                                  │
│ 오늘 무엇을 했나요?  중복 가능      │ ← Question
│                                  │
│ [이론수업] [토론수업] [발표수업]    │ ← OptionChips
│ [실습수업] [과제발표] [퀴즈]       │   (wrap layout)
│                                  │
│                          [완료]  │ ← 선택 후 활성화
└──────────────────────────────────┘
```

**스타일:**
- Padding: horizontal 20, top 24, bottom 20
- 배경: Dark - groupBackground, Light - white
- Corner radius: 12
- "완료" 버튼:
  - 비활성: gray30
  - 활성: Dark - darkMint1, Light - darkMint2

**동작:**
1. 화면 진입 시 `getDailyClassTypeList()` 호출 (`.task`)
2. 수업 유형 칩 탭: 선택/해제 (다중 선택 가능)
3. "완료" 버튼 탭:
   - `fetchDiaryQuestionnaire()` 호출
   - 성공 시 `showNextSession = true`
   - Step 2로 자동 스크롤 (0.5초 delay, easeIn)

#### 3.2.3 Step 2: 상세 질문 답변

**레이아웃:**
```
┌──────────────────────────────────┐
│ 수강신청                          │ ← Question 1
│ [널널해요] [무난해요] [어려웠어요]  │
│                                  │
│ ────────────────────────────     │ ← Divider
│                                  │
│ 드랍여부                          │ ← Question 2
│ [할 거에요] [모르겠어요] [안 할..] │
│                                  │
│ ────────────────────────────     │
│                                  │
│ 수업 첫인상                       │ ← Question 3
│ [기대돼요] [두려워요] [무난해요]   │
└──────────────────────────────────┘
```

**스타일:**
- Padding: horizontal 20, vertical 28
- 배경: Dark - groupBackground, Light - white
- Corner radius: 12
- Divider: 0.8pt, lightest
- Spacing: 20pt

**동작:**
- 각 질문마다 단일 선택 (QuestionAnswerSection)
- ⚠️ **미구현**: 선택한 답변 저장 로직 없음
  ```swift
  QuestionAnswerSection(questionItem: questionItem) { options in
      // TODO: 답변 저장 로직
  }
  ```

#### 3.2.4 추가 코멘트 섹션 (선택)

**레이아웃 (접힌 상태):**
```
┌──────────────────────────────────┐
│ 더 남기고 싶은 말을 작성해주세요.    │ ← semibold 15pt
│ 선택                         [⌄] │ ← regular 13pt
└──────────────────────────────────┘
```

**레이아웃 (펼친 상태):**
```
┌──────────────────────────────────┐
│ 더 남기고 싶은 말을 작성해주세요.    │
│ 선택                         [⌃] │
│ ──────────────────────────────── │
│ 오늘 수업에서 배운 내용,           │ ← Placeholder
│ 느낀 점 등을 간단하게              │
│ 적어보세요.                       │
│                                  │
│                                  │
│                           0/200 │ ← 글자 수
└──────────────────────────────────┘
```

**스타일:**
- Padding: horizontal 20, vertical 16
- 배경: Dark - groupBackground, Light - white
- Corner radius: 12
- TextField height: 120pt
- Divider: Dark - gray30.opacity(0.4), Light - lightest

**동작:**
- Header 탭: 확장/축소 (화살표 180도 회전)
- 텍스트 입력: extraReview State 업데이트
- 최대 200자

#### 3.2.5 제출 버튼

**레이아웃:**
```
┌──────────────────────────────────┐
│                                  │
│                        ┌─────┐  │
│                        │ 다음 │  │ ← width 122
│                        └─────┘  │
└──────────────────────────────────┘
```

**스타일:**
- Padding: top 4, bottom 40
- RoundedRectButton.medium

**동작:**
- ⚠️ **미구현**: 제출 로직 없음
  ```swift
  RoundedRectButton(label: "다음", type: .medium, disabled: disableButton) {
      Task {
          // TODO: Submit Diary
      }
  }
  ```
- 제출 후 `LectureDiaryConfirmView` 표시 예정

**배경색:**
- Light: lightField (#F2F2F2)
- Dark: black

---

### 3.3 LectureDiaryConfirmView - 완료 화면

#### 3.3.1 DisplayMode 종류

```swift
enum DisplayMode {
    case reviewMore      // 더 기록하기 버튼 표시
    case reviewDone      // 버튼 없이 완료만 표시
    case semesterEnd     // 강의평 작성하기 버튼 표시
}
```

#### 3.3.2 레이아웃

**공통 레이아웃:**
```
┌──────────────────────────────────┐
│                                  │
│                                  │
│         [heart.cat 이미지]        │
│                                  │
│    강의일기가 등록되었습니다.        │ ← semibold 15pt
│                                  │
│  작성한 강의일기는 더보기>강의일기장  │ ← regular 13pt
│  에서 확인할 수 있어요.             │   line height 145%
│                                  │
│  ┌────────────────────────┐     │ ← 조건부 버튼
│  │   더 기록하기      →    │     │   (reviewMore)
│  └────────────────────────┘     │   or
│  ┌────────────────────────┐     │   강의평 작성하기
│  │   강의평 작성하기   →   │     │   (semesterEnd)
│  └────────────────────────┘     │
│                                  │
│                                  │
│  ┌────────────────────────┐     │
│  │        홈으로           │     │ ← 하단 고정
│  └────────────────────────┘     │
└──────────────────────────────────┘
```

**스타일:**
- Padding: top 204, bottom 40, horizontal 32
- 배경: white (Dark 모드 미지원으로 보임)
- 조건부 버튼:
  - regular 15pt
  - Capsule shape
  - Border: Dark - gray30.opacity(0.4), Light - border
  - Padding: vertical 12, trailing 12, leading 20

**동작:**
- ⚠️ **미구현**: 모든 버튼 동작
  ```swift
  // "더 기록하기" / "강의평 작성하기"
  Button {
      displayMode == .reviewMore
      // FIXME: add another review
      ? moveToReviewTab()
      : moveToReviewTab()
  }

  // "홈으로"
  RoundedRectButton(label: "홈으로", ...) {
      print("button tapped")  // TODO: 구현 필요
  }
  ```

---

## 4. UI 컴포넌트 라이브러리

### 4.1 SemesterChip

**용도**: 학기 선택 칩

**Props:**
```swift
let semester: String          // "25-1", "25-2", "25-여름", etc.
let isSelected: Bool
let selected: () -> Void
```

**디자인:**
| 상태 | Font | Light 배경/글자 | Dark 배경/글자 |
|------|------|----------------|---------------|
| 선택됨 | semibold 15 | cyan / white | darkMint1 / white |
| 기본 | regular 15 | neutral98 / alternative | neutral5 / assistive |

- Shape: Capsule
- Padding: horizontal 24, vertical 8

**구현 코드:**
```swift
struct SemesterChip: View {
    let semester: String
    let isSelected: Bool
    let selected: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button {
            selected()
        } label: {
            Text(semester)
                .font(
                    isSelected
                    ? .system(size: 15, weight: .semibold)
                    : .system(size: 15)
                )
                .foregroundStyle(semesterChipForeground(isSelected))
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(semesterChipBackground(isSelected))
                .clipShape(Capsule())
        }
    }

    private func semesterChipForeground(_ selected: Bool) -> Color {
        selected
        ? .white
        : (colorScheme == .dark ? STColor.assistive : STColor.alternative)
    }

    private func semesterChipBackground(_ selected: Bool) -> Color {
        switch colorScheme {
        case .dark:
            selected ? STColor.darkMint1 : STColor.neutral5
        default:
            selected ? STColor.cyan : STColor.neutral98
        }
    }
}
```

---

### 4.2 OptionChip

**용도**: 단일/다중 선택 옵션 칩

**Props:**
```swift
let label: String
let state: ChipState           // selected / default / darkSelected / darkDefault
let select: () -> Void
```

**디자인 매트릭스:**

| State | Font | Label | Border (Width) | Border Color | Background |
|-------|------|-------|----------------|--------------|------------|
| **selected** | bold 14 | #059A94 | 1.0 | lightCyan | lightCyan 6% |
| **default** | regular 14 | black | 0.6 | neutral95 | clear |
| **darkSelected** | bold 14 | darkMint1 | 1.0 | darkMint2 | darkMint2 8% |
| **darkDefault** | regular 14 | assistive | 0.6 | gray30 80% | clear |

- Shape: Capsule
- Padding: horizontal 24, vertical 8

**ChipState 결정:**
```swift
ChipState(selected: Bool, colorScheme: ColorScheme)
// colorScheme과 selected 조합으로 자동 결정
```

**구현 코드:**
```swift
struct OptionChip: View {
    let label: String
    let state: ChipState
    let select: () -> Void

    var body: some View {
        Button {
            select()
        } label: {
            Text(label)
                .foregroundColor(state.labelColor)
                .font(state.font)
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
                .background(state.backgroundColor)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(state.borderColor, lineWidth: state.borderWidth)
                )
        }
    }
}

extension OptionChip {
    enum ChipState {
        case selected
        case `default`
        case darkSelected
        case darkDefault

        init(selected: Bool, colorScheme: ColorScheme) {
            if colorScheme == .dark {
                self = selected ? .darkSelected : .darkDefault
            } else {
                self = selected ? .selected : .default
            }
        }

        var font: Font {
            switch self {
            case .selected, .darkSelected: return STFont.bold14.font
            case .default, .darkDefault: return STFont.regular14.font
            }
        }

        var labelColor: Color {
            switch self {
            case .selected: return Color(hex: "#059A94")
            case .default: return .black
            case .darkSelected: return STColor.darkMint1
            case .darkDefault: return STColor.assistive
            }
        }

        var borderWidth: CGFloat {
            switch self {
            case .selected, .darkSelected: return 1
            case .default, .darkDefault: return 0.6
            }
        }

        var borderColor: Color {
            switch self {
            case .selected: return STColor.lightCyan
            case .default: return STColor.neutral95
            case .darkSelected: return STColor.darkMint2
            case .darkDefault: return STColor.gray30.opacity(0.8)
            }
        }

        var backgroundColor: Color {
            switch self {
            case .selected: return STColor.lightCyan.opacity(0.06)
            case .default: return .clear
            case .darkSelected: return STColor.darkMint2.opacity(0.08)
            case .darkDefault: return .clear
            }
        }
    }
}
```

---

### 4.3 QuestionAnswerSection

**용도**: 질문 + 답변 칩 리스트 섹션

**Props:**
```swift
var allowMultipleAnswers: Bool = false    // 다중 선택 가능 여부
let questionItem: QuestionItem
let selected: ([AnswerOption]) -> ()      // 선택 변경 시 콜백
```

**레이아웃:**
```
┌─────────────────────────────────┐
│ 질문 텍스트  서브질문 (optional)   │ ← HStack
│                                 │
│ [답변1] [답변2] [답변3]          │ ← WrappedOptionChipList
│ [답변4] [답변5]                  │
└─────────────────────────────────┘
```

**스타일:**
- 질문: semibold 15pt, primary
- 서브질문: regular 13pt, alternative (예: "중복 가능")
- Spacing: 12pt

**동작:**
- selectedOptions 변경 시 selected 클로저 호출
- ⚠️ **미구현**: WrappedOptionChipList (빈 파일)

**구현 코드:**
```swift
struct QuestionAnswerSection: View {
    var allowMultipleAnswers: Bool = false
    let questionItem: QuestionItem
    let selected: ([AnswerOption]) -> ()

    @State var selectedOptions: [AnswerOption] = []
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text(questionItem.question)
                    .font(STFont.semibold15.font)
                    .foregroundStyle(.primary)
                if let subLabel = questionItem.subQuestion {
                    Text(subLabel)
                        .font(STFont.regular13.font)
                        .foregroundStyle(STColor.alternative)
                }
                Spacer()
            }
            WrappedOptionChipList(
                selectedOptions: $selectedOptions,
                answerOptions: questionItem.options
            )
        }
        .onChange(of: selectedOptions) { options in
            selected(options)
        }
    }
}
```

---

### 4.4 ExtraReviewSection (ExtraCommentSection)

**용도**: 접을 수 있는 추가 코멘트 입력 섹션

**Props:**
```swift
@Binding var extraReview: String
```

**디자인 (Header):**
- "더 남기고 싶은 말을 작성해주세요." - semibold 15pt, primary
- "선택" - regular 13pt, Dark - gray30, Light - alternative
- 화살표: 확장 시 180도 회전

**디자인 (Body - 확장 시):**
- Divider: 0.8pt, Dark - gray30.opacity(0.4), Light - lightest
- UITextEditor:
  - Placeholder: "오늘 수업에서 배운 내용, 느낀 점 등을 간단하게\n적어보세요."
  - Font: regular 14pt
  - Height: 120pt
- 글자 수: bold 15pt (cyan) + regular 14pt (alternative/darkerGray)
  - 형식: "0/200"

**스타일:**
- Padding: horizontal 20, vertical 16
- 배경: Dark - groupBackground, Light - white
- Corner radius: 12

**구현 코드:**
```swift
struct ExtraReviewSection: View {
    @Binding var extraReview: String
    @State private var extraReviewExpanded: Bool = false

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            headerView()
            if extraReviewExpanded {
                ExtraCommentTextField(extraReview: $extraReview)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            colorScheme == .dark ? STColor.groupBackground : .white
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func headerView() -> some View {
        HStack {
            HStack(spacing: 6) {
                Text("더 남기고 싶은 말을 작성해주세요.")
                    .font(STFont.semibold15.font)
                    .foregroundStyle(.primary)
                Text("선택")
                    .font(STFont.regular13.font)
                    .foregroundStyle(
                        colorScheme == .dark
                        ? STColor.gray30
                        : STColor.alternative
                    )
            }
            Spacer()
            Image("chevron.down")
                .rotationEffect(.init(degrees: extraReviewExpanded ? 180.0 : 0))
        }
        .onTapGesture {
            withAnimation {
                extraReviewExpanded.toggle()
            }
        }
    }
}

struct ExtraCommentTextField: View {
    @Binding var extraReview: String
    @State private var wordCount = 0
    private let wordLimit = 200

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Divider().frame(height: 0.8)
            .frame(maxWidth: .infinity)
            .foregroundStyle(
                colorScheme == .dark
                ? STColor.gray30.opacity(0.4)
                : STColor.lightest
            )
        VStack(spacing: 0) {
            UITextEditor(
                "오늘 수업에서 배운 내용, 느낀 점 등을 간단하게\n적어보세요.",
                text: $extraReview
            ) { textView in
                textView.backgroundColor = .clear
                textView.textContainerInset = .zero
                textView.textContainer.lineFragmentPadding = 0
                textView.font = STFont.regular14
            } onChange: { textView in
                wordCount = textView.text.count
            }
            .padding(.top, 8)

            HStack {
                Spacer()
                Text("\(wordCount)")
                    .font(STFont.bold15.font)
                    .foregroundColor(STColor.cyan) +
                Text("/\(wordLimit)")
                    .font(STFont.regular14.font)
                    .foregroundColor(
                        colorScheme == .dark
                        ? STColor.darkerGray
                        : STColor.alternative
                    )
            }
        }
        .frame(height: 120)
    }
}
```

---

### 4.5 ExpandableDiarySummaryCell

**용도**: 접을 수 있는 강의일기 요약 카드

**Props:**
```swift
let diaryList: [DiarySummary]          // 같은 날짜의 여러 강의
let deleteDiary: (String) -> Void      // 삭제 콜백
```

**레이아웃 (Header - 항상 표시):**
```
┌─────────────────────────────────┐
│ 2025.11.29  금                   │ ← semibold 15, spacing 6
│ 시각디자인기초, 배구          [⌄]│ ← regular 14, alternative
└─────────────────────────────────┘
```

**레이아웃 (Body - 확장 시):**
```
┌─────────────────────────────────┐
│ ┌───────────────────────────┐  │
│ │ 시각디자인기초        [🗑] │  │ ← 강의명 + 삭제
│ │                           │  │
│ │ 수강신청    널널해요        │  │ ← Question-Answer rows
│ │ 드랍여부    모르겠어요       │  │
│ │ 수업 첫인상  두려워요        │  │
│ │ 남기고      오티 했어용...   │  │ ← 추가 코멘트 (optional)
│ │ 싶은 말                    │  │
│ └───────────────────────────┘  │
│                                 │
│ ┌───────────────────────────┐  │
│ │ 배구                  [🗑] │  │
│ │ ...                       │  │
│ └───────────────────────────┘  │
└─────────────────────────────────┘
```

**스타일:**
- Header: semibold 15pt (날짜/요일), regular 14pt (강의명)
- 카드 배경: Dark - groupBackground, Light - neutral98
- Corner radius: 4
- Spacing: 6pt (Question-Answer rows), 16pt (카드 간)
- Padding:
  - 전체: top 16, bottom 16~32, horizontal 20
  - 카드: horizontal 16, top 16, bottom 20

**동작:**
- Header 탭: 확장/축소, 화살표 90도 회전
- 휴지통 아이콘 탭: "'{강의명}' 강의일기를 삭제하시겠습니까?" Alert

**구현 코드:**
```swift
struct ExpandableDiarySummaryCell: View {
    let diaryList: [DiarySummary]
    @State private var isExpanded: Bool = false
    @State private var showDeleteDiaryAlert: Bool = false
    @State private var selectedDiary: DiarySummary?

    let deleteDiary: (String) -> Void

    private var joinedLectureTitle: String {
        diaryList.map { $0.lectureTitle }.joined(separator: ", ")
    }

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            diarySummaryHeader
            if isExpanded {
                VStack(spacing: 16) {
                    ForEach(diaryList, id: \.id) { diary in
                        diarySummaryCard(diary) {
                            selectedDiary = diary
                            showDeleteDiaryAlert = true
                        }
                    }
                }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, isExpanded ? 32 : 16)
        .padding(.horizontal, 20)
        .alert(
            Text("'\(selectedDiary?.lectureTitle ?? "")' 강의일기를 삭제하시겠습니까?"),
            isPresented: $showDeleteDiaryAlert
        ) {
            Button("취소", role: .cancel) {}
            Button("확인", role: .destructive) {
                if let selectedDiary = selectedDiary {
                    deleteDiary(selectedDiary.id)
                }
            }
        }
    }

    private var diarySummaryHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                if let diary = diaryList.first {
                    Text(diary.dateString)
                    Text(diary.weekdayString)
                    Spacer()
                }
            }
            .font(STFont.semibold15.font)
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(joinedLectureTitle)
                        .foregroundStyle(STColor.alternative)
                        .font(STFont.regular14.font)
                    Spacer()
                    Image("daily.review.chevron.right")
                        .rotationEffect(isExpanded ? .degrees(-90) : .degrees(90))
                }
                .padding(.vertical, 8)
            }
        }
    }

    @ViewBuilder
    private func diarySummaryCard(
        _ diary: DiarySummary,
        _ onTap: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 6) {
            VStack(spacing: 16) {
                HStack {
                    Text(diary.lectureTitle)
                        .font(STFont.regular14.font)
                        .foregroundStyle(
                            colorScheme == .dark
                            ? STColor.assistive
                            : STColor.alternative
                        )
                    Spacer()
                    Button {
                        onTap()
                    } label: {
                        Image("daily.review.trash")
                    }
                }
                VStack(spacing: 6) {
                    ForEach(diary.shortQuestionReplies, id: \.question) {
                        DiaryQuestionAnswerRow(question: $0.question, answer: $0.answer)
                    }
                    if let comment = diary.comment {
                        DiaryQuestionAnswerRow(question: "남기고 싶은 말", answer: comment)
                    }
                }
            }
            .padding([.horizontal, .top], 16)
            .padding(.bottom, 20)
            .background(
                colorScheme == .dark
                ? STColor.groupBackground
                : STColor.neutral98
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}
```

---

### 4.6 DiaryQuestionAnswerRow

**용도**: 질문-답변 행 (읽기 전용)

**Props:**
```swift
let question: String
let answer: String
```

**레이아웃:**
```
┌─────────────────────────────────┐
│ [질문____] 답변 텍스트...         │
│  80pt 고정                       │
└─────────────────────────────────┘
```

**스타일:**
- HStack: alignment .top, spacing 16
- 질문:
  - Width: 80pt (고정)
  - Font: bold 14pt
  - Color: Dark - alternative, Light - assistive
- 답변:
  - Width: 나머지
  - Font: regular 14pt
  - Color: Dark - assistive, Light - darkerGray

**구현 코드:**
```swift
struct DiaryQuestionAnswerRow: View {
    let question: String
    let answer: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(question)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(
                    colorScheme == .dark
                    ? STColor.alternative
                    : STColor.assistive
                )
                .frame(width: 80, alignment: .leading)
            Text(answer)
                .font(.system(size: 14))
                .foregroundStyle(
                    colorScheme == .dark
                    ? STColor.assistive
                    : STColor.darkerGray
                )
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .multilineTextAlignment(.leading)
    }
}
```

---

### 4.7 WrappedOptionChipList

**용도**: Wrap 레이아웃으로 배치되는 옵션 칩 리스트

**Props:**
```swift
@Binding var selectedOptions: [AnswerOption]
let answerOptions: [AnswerOption]
```

**상태:**
- ⚠️ **미구현**: 전체 구현 필요 (빈 파일)
  ```swift
  var body: some View {
      ForEach(answerOptions, id: \.id) { label in
          // TODO: OptionChip 배치 로직 (Wrap layout)
      }
  }
  ```

---

## 5. 디자인 시스템 추가사항

### 5.1 새로운 색상

```swift
// Mint 계열 (강의일기 테마)
static let lightCyan: Color = .init(hex: "#1BD0C8")
static let darkMint1: Color = .init(hex: "#00B8B0")
static let darkMint2: Color = .init(hex: "#1CA6A0")

// Neutral 계열
static let neutral5: Color = .init(hex: "#222222")
static let neutral15: Color = .init(hex: "#3C3C3C")
static let neutral98: Color = .init(hex: "#F7F7F7")

// 보더/배경
static let disabledLine: Color = .init(hex: "#DCDCDE")
static let border: Color = .init(hex: "E4E4E5")
static let lightField: Color = .init(hex: "#F2F2F2")
static let lightest: Color = .init(hex: "#F5F5F5")
```

### 5.2 새로운 아이콘

| 파일명 | 용도 | 사이즈 | 모드 |
|--------|------|--------|------|
| `daily.review.chevron.right` | 우측 화살표 | 2x, 3x | 공통 |
| `daily.review.trash` | 휴지통 (삭제) | 2x, 3x | Light/Dark 분리 |
| `daily.review.xmark` | X 닫기 | 2x, 3x | 공통 |
| `heart.cat` | 완료 화면 이미지 | 2x, 3x | 공통 |

### 5.3 group.background 색상 변경

```json
// Dark 모드에서 더 밝은 회색으로 변경
{
  "blue": "0x2B",    // 0.169 -> 0x2B (43)
  "green": "0x2B",
  "red": "0x2B"
}
```

### 5.4 RoundedRectButton Dark 모드 지원

**변경 전:**
- 배경: disabled - neutral95, active - cyan

**변경 후:**
- 배경:
  - Disabled: Dark - darkerGray, Light - neutral95
  - Active: Dark - darkMint1, Light - lightCyan
- 글자: disabled - assistive, active - white (공통)

### 5.5 기타 변경사항

**Semester.mediumString() 추가:**
```swift
func mediumString() -> String {
    switch self {
    case .first: return "1"
    case .second: return "2"
    case .summer: return "여름"
    case .winter: return "겨울"
    }
}
```

**UITextEditor 개선:**
- Placeholder의 trailing constraint 추가하여 멀티라인 대응

---

## 6. 미구현 사항 (Critical)

### 6.1 EditLectureDiaryScene

**1. 답변 선택 핸들링 (Step 2)**
```swift
// 현재 코드
QuestionAnswerSection(questionItem: questionItem) { options in
    // TODO: 선택한 답변을 어딘가에 저장해야 함
}
```
**필요한 구현:**
- 각 질문의 선택된 답변을 State로 관리
- 모든 질문 답변 완료 시 "다음" 버튼 활성화

**2. 일기 제출 로직**
```swift
// 현재 코드
RoundedRectButton(label: "다음", ...) {
    Task {
        // TODO: DiaryDto 생성 및 submitDiary 호출
    }
}
```
**필요한 구현:**
- DiaryDto 구조체 생성:
  ```swift
  DiaryDto(
      lectureId: lecture.referenceId,
      dailyClassTypes: classCategoryList.map(\.content),
      questionAnswers: selectedAnswers.map {
          QuestionAnswerDto(questionId: $0.questionId, answerIndex: $0.answerIndex)
      },
      comment: extraReview
  )
  ```
- `viewModel.submitDiary()` 호출
- 성공 시 `showConfirmView = true`

**3. 완료 화면 dismiss**
```swift
// 현재 코드
if showConfirmView {
    LectureDiaryConfirmView(displayMode: .reviewMore) {
        // TODO: 다른 리뷰 진행 로직
    }
}
```

---

### 6.2 LectureDiaryConfirmView

**1. 홈으로 버튼**
```swift
// 현재 코드
RoundedRectButton(label: "홈으로", ...) {
    print("button tapped")  // TODO: dismiss to home
}
```
**필요한 구현:**
- 전체 네비게이션 스택 dismiss
- 탭을 시간표 탭으로 변경

**2. 더 기록하기 / 강의평 작성 버튼**
```swift
// 현재 코드
Button {
    displayMode == .reviewMore
    // FIXME: add another review
    ? moveToReviewTab()
    : moveToReviewTab()
}
```
**필요한 구현:**
- `reviewMore`: 다음 강의에 대한 EditLectureDiaryScene 표시
- `semesterEnd`: 강의평 작성 화면으로 이동

---

### 6.3 WrappedOptionChipList (Critical)

**현재 상태:**
```swift
var body: some View {
    ForEach(answerOptions, id: \.id) { label in
        // TODO: Wrap layout 구현
    }
}
```

**필요한 구현:**
- FlowLayout 또는 LazyVGrid를 사용한 Wrap 레이아웃
- OptionChip 배치
- 단일/다중 선택 로직
- selectedOptions Binding 업데이트

**예상 구현:**
```swift
// SwiftUI의 Layout Protocol 또는 커스텀 ViewBuilder
WrappingHStack(alignment: .leading, spacing: 8) {
    ForEach(answerOptions, id: \.id) { option in
        OptionChip(
            label: option.content,
            state: .init(
                selected: selectedOptions.contains(option),
                colorScheme: colorScheme
            )
        ) {
            if allowMultipleAnswers {
                toggleSelection(option)
            } else {
                selectedOptions = [option]
            }
        }
    }
}
```

---

### 6.4 LectureDiaryListView

**데이터 로딩 누락:**
```swift
// SettingScene.swift
SettingsLinkItem(title: "강의 일기장") {
    LectureDiaryListView(viewModel: .init(container: viewModel.container))
}
```

**필요한 추가:**
```swift
SettingsLinkItem(title: "강의 일기장") {
    LectureDiaryListView(viewModel: .init(container: viewModel.container))
        .task {
            await viewModel.getDiaryListCollection()
        }
}
```

---

## 7. 마이그레이션 체크리스트

### 7.1 필수 UI 구현
- [ ] LectureDiaryListView
  - [ ] Empty State
  - [ ] Filled State (학기 칩 + 일기 카드)
  - [ ] 삭제 기능
- [ ] EditLectureDiaryScene
  - [ ] Header (제목 + X 버튼)
  - [ ] Step 1: 수업 유형 선택
  - [ ] Step 2: 상세 질문 답변
  - [ ] 추가 코멘트 섹션
  - [ ] 제출 버튼
- [ ] LectureDiaryConfirmView
  - [ ] 3가지 DisplayMode 지원

### 7.2 UI 컴포넌트 (7개)
- [ ] SemesterChip
- [ ] OptionChip
- [ ] QuestionAnswerSection
- [ ] ExtraReviewSection
- [ ] ExpandableDiarySummaryCell
- [ ] DiaryQuestionAnswerRow
- [ ] ⚠️ WrappedOptionChipList (미구현)

### 7.3 디자인 시스템
- [ ] 새로운 색상 10개 추가
- [ ] 새로운 아이콘 4개 추가
- [ ] group.background 색상 업데이트
- [ ] RoundedRectButton Dark 모드 지원
- [ ] Semester.mediumString() 추가

### 7.4 Critical 미구현 완성
- [ ] ⚠️ EditLectureDiaryScene 답변 선택 핸들링
- [ ] ⚠️ EditLectureDiaryScene 제출 로직
- [ ] ⚠️ LectureDiaryConfirmView 버튼 동작
- [ ] ⚠️ WrappedOptionChipList 전체 구현
- [ ] LectureDiaryListView 데이터 로딩

### 7.5 테스트
- [ ] Light/Dark 모드 모든 화면 확인
- [ ] 빈 상태 → 작성 → 완료 플로우
- [ ] 다중 일기 표시 및 삭제
- [ ] 학기 필터링 동작 확인
- [ ] 긴 텍스트 입력 시 UI 동작

---

## 8. 주의사항

1. **WrappedOptionChipList는 완전히 비어있음** - 가장 먼저 구현 필요
2. **제출 로직이 전혀 없음** - DiaryDto 생성 및 submitDiary 호출 필요
3. **답변 선택 상태 관리 없음** - State 추가 필요
4. **완료 화면 버튼 동작 없음** - 네비게이션 로직 추가 필요
5. **모든 UI는 Light/Dark 모드 대응** - 색상 분기 확인 필수

---

**문서 버전**: 2.0 (UI/UX 중심)
**최종 수정일**: 2025-11-29
**작성자**: Claude Code (PR #391 분석 기반)
