//
//  TimetableScene+Toolbar.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

extension TimetableScene {
    var toolbarContent: some View {
        timetableToolbarView
            .frame(height: 40)
            .clipped()
    }

    private var timetableToolbarView: some View {
        HStack(spacing: 0) {
            ToolbarButton(image: TimetableAsset.navMenu.image) {
                timetableViewModel.isMenuPresented.toggle()
            }
            .timetableMenuSheet(isPresented: $timetableViewModel.isMenuPresented, viewModel: timetableViewModel)
            toolbarTitle
            Spacer()
            ToolbarButton(image: TimetableAsset.navList.image) {
                timetableViewModel.paths = [.lectureList]
            }
        }
    }

    @ViewBuilder
    private var toolbarTitle: some View {
        Text(timetableViewModel.timetableTitle)
            .font(.system(size: 17, weight: .bold))
            .minimumScaleFactor(0.9)
            .lineLimit(1)
            .padding(.trailing, 8)
        Text(TimetableStrings.timetableToolbarTotalCredit(timetableViewModel.totalCredit))
            .font(.system(size: 12))
            .foregroundColor(Color(UIColor.secondaryLabel))
    }
}

extension TimetableScene {
    @ToolbarContentBuilder
    func toolbarContentForNewDesign() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button {
                timetableViewModel.isMenuPresented.toggle()
            } label: {
                TimetableAsset.navMenu.swiftUIImage
            }
            .timetableMenuSheet(isPresented: $timetableViewModel.isMenuPresented, viewModel: timetableViewModel)
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                notificationCenter.post(NavigateToBookmarkMessage())
            } label: {
                TimetableAsset.navBookmark.swiftUIImage
            }
            addLectureMenu
        }
    }

    @ViewBuilder
    private var addLectureMenu: some View {
        Menu {
            Section(TimetableStrings.timetableAddMenuSectionAdd) {
                Button {
                    notificationCenter.post(NavigateToSearchMessage())
                } label: {
                    Label {
                        Text(TimetableStrings.timetableAddMenuSearch)
                    } icon: {
                        TimetableAsset.navMenuSearch.swiftUIImage
                    }
                }

                Button {
                    timetableViewModel.presentLectureCreateScene()
                } label: {
                    Label {
                        Text(TimetableStrings.timetableAddMenuDirect)
                    } icon: {
                        TimetableAsset.navMenuPencil.swiftUIImage
                    }
                }
            }

            Section(TimetableStrings.timetableAddMenuSectionList) {
                Button {
                    timetableViewModel.paths = [.lectureList]
                } label: {
                    Label {
                        Text(TimetableStrings.timetableAddMenuCurrentList)
                    } icon: {
                        TimetableAsset.navMenuList.swiftUIImage
                    }
                }

                Button {
                    timetableViewModel.paths = [.vacancyList]
                } label: {
                    Label {
                        Text(TimetableStrings.timetableAddMenuVacancyList)
                    } icon: {
                        TimetableAsset.navMenuVacancy.swiftUIImage
                    }
                }
            }
        } label: {
            TimetableAsset.navPlus.swiftUIImage
        }
    }
}
