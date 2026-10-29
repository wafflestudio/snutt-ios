# Evaluation Home 리팩터링 설계

## 목표

`EvaluationHomeScene`의 화면 구조를 정보 단위로 읽기 쉽게 정리한다. 사용자에게 보이는 UI는 거의 그대로 유지한다.

초기 로딩의 전체 화면 `ProgressView`는 최종 로드 화면과 같은 구조를 가진 skeleton 로딩 상태로 바꾼다. Evaluations의 로드 실패 처리는 별도 실패 화면이나 실패 footer 대신 앱 공통 alert 패턴에 맞춘다.

## 범위

- `EvaluationHomeScene`은 navigation, load-state routing, refresh, destination wiring의 최상위 소유자로 유지한다.
- Evaluations UI 컴포넌트는 의미 있는 정보 단위만 분리한다.
- skeleton 로딩은 home의 초기 로딩에만 사용한다.
- 현재 spacing, typography, color, action, sort 동작, refresh 동작은 최대한 유지한다.
- Evaluations home과 see-all의 명시적 로드 실패는 전용 실패 화면이나 실패 footer가 아니라 `errorAlertHandler`로 노출한다.
- 큰 view-state layer, section enum, shimmer system, 무관한 Evaluations redesign은 도입하지 않는다.

## 제안 구조

`EvaluationHomeScene`은 화면의 큰 형태를 직접 보여주는 구조를 유지한다.

```text
EvaluationHomeScene
  NavigationStack
    content state switch
      loadingScrollContent
      loadedScrollContent
```

loaded scroll content와 loading scroll content는 같은 section-level 구조를 사용한다.

```text
ScrollView
  LazyVStack
    EvaluationSearchEntryView
    EvaluationMainFeedSection
      EvaluationSortToggle
      LectureEvaluationCell...
      EvaluationHomeSectionLink
    EvaluationTakenLectureSection
      TakenLectureCell...
```

`EvaluationHomeContentView`, `EvaluationHomeLoadingView` 같은 wrapper view는 추가하지 않는다. 이런 wrapper는 유용한 hierarchy를 드러내기보다 숨길 가능성이 높다.

## 컴포넌트

### `EvaluationMainFeedSection`

main feed 정보 단위를 소유한다.

- sort toggle
- preview evaluation rows
- empty row text
- "강의평 전체보기" link

loaded/loading을 표현할 수 있는 mode-like input을 받는다. loaded mode에서는 `EvaluationFeedContent`, selected sort, available sorts, action closure들을 받는다. loading mode에서는 placeholder sort 값과 placeholder `LectureEvaluationCell` row 3개를 렌더링한다.

### `EvaluationTakenLectureSection`

taken lecture 정보 단위를 소유한다.

- colored header row
- taken lecture title
- "나의 강의평" link
- taken lecture rows

loaded mode에서는 `TakenLectureFeedContent`와 action closure들을 받는다. loading mode에서는 고정 placeholder header와 placeholder `TakenLectureCell` row 2개를 렌더링한다.

### `EvaluationHomeSectionLink`

중복을 줄이거나 section 파일을 작게 유지하는 데 도움이 될 때만 추출한다. 현재 height, padding, typography, chevron, animatable button style을 유지하는 작은 button row여야 한다.

## Preview Support

구현 후 SwiftUI preview에서 loading 상태와 data loaded 상태를 각각 확인할 수 있어야 한다.

- `EvaluationHomeScene` 또는 home content를 preview할 수 있는 entry point는 `.loading`과 `.loaded(EvaluationHomeContent)`를 명시적으로 주입할 수 있어야 한다.
- loading preview는 실제 초기 로딩과 같은 skeleton section 구조를 보여준다.
- loaded preview는 대표적인 `EvaluationHomeContent` fixture를 사용해 main feed와 taken lecture section이 모두 보이는 상태를 보여준다.
- 필요한 preview fixture는 Evaluations UI 근처에 file-private helper나 preview-only static value로 둔다. production repository나 network dependency에 의존하지 않는다.
- `EvaluationMainFeedSection`과 `EvaluationTakenLectureSection`을 별도 파일로 추출한다면 각 section도 loading/loaded preview를 제공한다.
- preview를 위해 production view model API를 넓히지 않는다. 필요하면 scene 내부 content builder 또는 preview-only initializer처럼 UI 상태 주입에만 한정된 방법을 사용한다.

## Skeleton Loading

초기 로딩은 loaded layout과 같은 `ScrollView + LazyVStack` 구조로 렌더링한다. loading tree를 별도 전체 화면 loading component로 만들지 않는다.

placeholder content는 가능한 한 실제 컴포넌트 구조를 사용한다.

- `EvaluationSearchEntryView`는 같은 위치에 둔다.
- `EvaluationMainFeedSection`은 placeholder sort와 placeholder `LectureEvaluationCell` row 3개를 렌더링한다.
- `EvaluationTakenLectureSection`은 placeholder header와 placeholder `TakenLectureCell` row 2개를 렌더링한다.
- section link와 button은 원래 위치에 남긴다.
- `.redacted(reason: .placeholder)`는 section 또는 row 단위에 적용해 skeleton 크기가 실제 content를 따르게 한다.

placeholder fixture는 사용하는 컴포넌트 근처에 `private static` 값이나 file-private helper로 둔다. 실제 데이터와 비슷한 row height가 나오도록 현실적인 길이의 한국어 텍스트를 사용한다. 이 데이터는 skeleton 렌더링 밖의 production behavior로 새어나가면 안 된다.

custom shimmer는 도입하지 않는다. 앱의 기존 default spring animation style을 사용해 redacted content에서 loaded content로 안정적으로 전환하는 것이 목표다.

## 동작

- 초기 `.loading`은 `ProgressView` 대신 skeleton content를 보여준다.
- `.loaded`는 실제 content와 현재 interaction을 보여준다.
- home load failure는 `errorAlertHandler.withAlert`로 표시한다. 초기 load failure 때문에 `ContentUnavailableView`를 보여주지 않는다.
- 초기 load가 실패하면 이후 성공적인 load가 일어날 때까지 skeleton을 alert 뒤에 유지한다. retry는 skeleton scroll surface의 pull-to-refresh로 수행한다. 별도 retry button은 추가하지 않는다.
- pull-to-refresh는 refresh된 데이터가 들어오기 전까지 기존 loaded content를 유지한다. refresh 실패 시 기존 content를 유지하고 alert를 보여준다.
- sort 변경은 request가 진행되는 동안 기존 optimistic selected sort 동작을 유지하고 skeleton을 보여주지 않는다. sort load failure가 나면 이전 selected sort와 이전 feed content로 되돌리고 alert를 보여준다.
- loaded home에 taken lecture feed가 없으면, loading 때 보였던 taken lecture skeleton은 load 이후 사라진다. 이 section은 main feed 아래에 있고, section 존재 여부를 예측하기 위한 추가 state를 만들지 않는 편이 낫기 때문에 허용한다.

## See All 에러 처리와 Pagination

`EvaluationSeeAllScene`도 같은 alert-driven failure model을 사용한다.

- 초기 list load는 loading surface를 유지한다.
- 초기 load failure는 alert를 보여주고 이후 성공적인 load가 일어날 때까지 loading surface를 유지한다. retry는 pull-to-refresh로 수행한다. 별도 retry button은 추가하지 않는다.
- refresh failure는 이전 loaded list를 유지하고 alert를 보여준다.
- sort failure는 이전 selected sort와 마지막 matching list content로 되돌리고 alert를 보여준다. 실패 화면으로 이동하지 않는다.
- pagination은 강의검색 infinite-scroll pattern을 따른다. pagination spinner, failed footer, retry footer, pagination alert를 렌더링하지 않는다. list는 `ExpandableLectureListView`처럼 현재 scroll position이 마지막 몇 개 evaluation 근처에 도달했을 때 조용히 다음 page를 prefetch한다.
- pagination failure는 기존 list를 유지하고 내부 loading flag만 해제하며 화면에는 드러내지 않는다. 이후 bottom-near scroll event에서 자연스럽게 재시도할 수 있다. retry를 막기 위한 별도 failed state나 trigger 저장소는 두지 않고, 중복 요청 방지는 in-flight loading flag와 stale request guard로 처리한다.

이렇게 하면 `EvaluationSeeAllScene`의 `ContentUnavailableView`가 필요 없어지고 pagination footer UI도 완전히 제거된다.

## Data Flow

Evaluations view model은 load error를 display string으로 변환하지 않는다. render state는 실제로 화면에 보여줄 수 있는 content만 표현한다.

- home loading content: `homeState == .loading`
- home loaded content: `homeState == .loaded(EvaluationHomeContent)`
- see-all loading content: `loadState == .loading`
- see-all loaded content: `loadState == .loaded([LectureEvaluation])`

load와 sort 메서드는 error를 위로 throw한다. `EvaluationHomeScene`과 `EvaluationSeeAllScene`은 `@Environment(\.errorAlertHandler)`를 주입받고 `onLoad`, `refreshable`, sort-selection 작업을 `errorAlertHandler.withAlert`로 감싼다. broad pattern은 기존 `FriendsScene`을 따른다.

pagination load-more는 scroll-driven background work이므로 다르게 취급한다. 강의검색과 맞춰 failure는 화면에 드러내지 않는다. view model은 내부 `isLoadingMore`, `canLoadMore`, request generation bookkeeping으로 중복 request와 stale result 적용을 막는다. view는 visible footer가 아니라 scroll position 또는 bottom-near row appearance를 통해 load-more를 트리거한다.

`EvaluationError`는 `LocalizedError`를 채택해 `ErrorAlertHandler`가 Evaluations-specific message를 보여줄 수 있게 한다. view model이 error를 display string으로 바꾸면 안 된다. 특히 `missingRequiredSort`는 유용한 localized description 또는 recovery suggestion을 제공해야 한다.

Evaluations home과 see-all failure는 alert-driven으로 처리할 수 있으므로 Evaluations에서 사용하는 shared `LoadState`에는 `.failed(String)` case가 더 이상 필요 없다. `EvaluationSeeAllViewModel`은 loaded evaluations를 두 곳에 저장하지 않는다. 화면에 보이는 list의 single source of truth는 `loadState == .loaded([LectureEvaluation])`이다. pagination state는 renderable enum일 필요가 없다. cursor, can-load-more, loading flag, request generation은 `LectureSearchResultDataSource`의 역할처럼 view model 내부 private bookkeeping으로 유지한다.

repository, use case, destination model 변경은 필요 없다.

## 검증

- Swift 파일을 추가한 뒤 Tuist project를 재생성한다: `tuist generate --no-open`.
- Evaluations module을 build한다: `tuist build Evaluations`.
- 필요하면 formatting을 실행한다: `just format`.
- 구현 중 수동으로 보존하기 위험한 동작이 발견되지 않는 한, 이 refactor 범위에서는 새 test를 추가하지 않는다.
- SwiftUI preview에서 loading 상태와 loaded 상태가 각각 렌더링되는지 수동 확인한다. 필수 검증은 module build다.

## Non-Goals

- Evaluations home screen의 시각적 redesign은 하지 않는다.
- custom shimmer나 shared skeleton framework는 만들지 않는다.
- 기존 placeholder를 넘어서는 navigation destination 구현은 하지 않는다.
- `EvaluationSeeAllScene`의 시각적 redesign은 하지 않는다. pagination은 강의검색처럼 화면에 드러나지 않아야 한다.
- repository, API model, business logic은 변경하지 않는다.
