// SPDX-FileCopyrightText: 2023 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

struct DictionariesView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @State private var selectedDictSetting: DictSetting?
    @State var isShowingSkkservSheet: Bool = false

    var body: some View {
        VStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(UserDict.userDictFilename)
                            .font(.body)
                        loadingStatus(of: settingsViewModel.userDictLoadingStatus)
                    }
                } header: {
                    Text("SettingsNameUserDictTitle")
                }
                Section {
                    HStack {
                        Toggle(isOn: $settingsViewModel.skkservDictSetting.enabled) {
                            Text("\(settingsViewModel.skkservDictSetting.address):\(String(settingsViewModel.skkservDictSetting.port))")
                                .font(.body)
                        }
                        Button {
                            isShowingSkkservSheet = true
                        } label: {
                            Image(systemName: "info.circle")
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                        .buttonStyle(.borderless)
                    }
                } header: {
                    Text("SKKServ")
                }
                Section {
                    List {
                        ForEach($settingsViewModel.dictSettings) { dictSetting in
                            HStack(alignment: .top) {
                                Toggle(isOn: dictSetting.enabled) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(dictSetting.id)
                                            .font(.body)
                                        loadingStatus(setting: dictSetting.wrappedValue)
                                    }
                                }
                                .toggleStyle(.switch)
                                Button {
                                    selectedDictSetting = dictSetting.wrappedValue
                                } label: {
                                    Image(systemName: "info.circle")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                }
                                .buttonStyle(.borderless)
                            }
                            .padding(EdgeInsets(top: 4, leading: 2, bottom: 4, trailing: 2))
                        }.onMove { from, to in
                            settingsViewModel.dictSettings.move(fromOffsets: from, toOffset: to)
                        }
                    }
                } header: {
                    Text("SettingsFileDictionariesTitle")
                    Text("SettingsFileDictionariesSubtitle")
                        .font(.subheadline)
                        .fontWeight(.light)
                } footer: {
                    Button {
                        NSWorkspace.shared.open(settingsViewModel.dictionariesDirectoryUrl)
                    } label: {
                        Text("SettingsOpenDictionaryFolder")
                    }
                    .padding(.top)
                }
            }
            .formStyle(.grouped)
            .sheet(item: $selectedDictSetting) { dictSetting in
                DictionaryView(
                    dictSetting: $selectedDictSetting,
                    filename: dictSetting.filename,
                    encoding: dictSetting.encoding
                )
            }
            .sheet(isPresented: $isShowingSkkservSheet) {
                SKKServDictView(settingsViewModel: settingsViewModel, isShowSheet: $isShowingSkkservSheet)
            }
            Text("SettingsNoteDictionaries")
                .font(.subheadline)
                .padding([.bottom, .leading, .trailing])
            Spacer()
        }
    }
    
    private func footnoteText(_ string: String) -> some View {
        Text(string).font(.footnote)
    }

    private func loadingStatus(setting: DictSetting) -> AnyView {
        if let status = settingsViewModel.dictLoadingStatuses[setting.id] {
            return AnyView(loadingStatus(of: status))
        } else if !setting.enabled {
            // 元々無効になっていて、設定を今回の起動で切り替えてない辞書
            return AnyView(footnoteText(String(localized: "LoadingStatusDisabled")))
        } else {
            return AnyView(footnoteText(String(localized: "LoadingStatusUnknown")))
        }
    }

    private func loadingStatus(of status: DictLoadStatus) -> AnyView {
        switch status {
        case .loaded(let entryCount, let failureLineNumbers):
            let failureCount = failureLineNumbers.count
            if failureCount == 0 {
                return AnyView(footnoteText(String(localized: "LoadingStatusLoaded \(entryCount)")))
            } else {
                return AnyView(
                    VStack(alignment: .leading) {
                        footnoteText(String(localized: "LoadingStatusLoaded \(entryCount) WithError \(failureCount)"))
                        List {
                            DisclosureGroup("ErrorLineNumber") {
                                Text(failureLineNumbers.map{ String($0) }.joined(separator: ", "))
                            }
                        }
                    }
                )
            }
        case .loading:
            return AnyView(footnoteText(String(localized: "LoadingStatusLoading")))
        case .disabled:
            return AnyView(footnoteText(String(localized: "LoadingStatusDisabled")))
        case .fail(let error):
            return AnyView(footnoteText(String(localized: "LoadingStatusError \(error as NSError)")))
        }
    }
}

struct DictionariesView_Previews: PreviewProvider {
    enum DictionariesViewPreviewError: Error {
        case dummy
    }

    static var previews: some View {
        let dictSettings = [
            DictSetting(filename: "SKK-JISYO.success_only", enabled: true, encoding: .japaneseEUC),
            DictSetting(filename: "SKK-JISYO.L", enabled: true, encoding: .japaneseEUC),
            DictSetting(filename: "SKK-JISYO.sample.utf-8", enabled: false, encoding: .utf8),
            DictSetting(filename: "SKK-JISYO.dummy", enabled: true, encoding: .utf8),
            DictSetting(filename: "SKK-JISYO.error", enabled: true, encoding: .utf8),
        ]
        let settings = try! SettingsViewModel(dictSettings: dictSettings)
        settings.dictLoadingStatuses = [
            "SKK-JISYO.success_only": .loaded(success: 123456, failureLineNumbers: []),
            "SKK-JISYO.L": .loaded(success: 123456, failureLineNumbers: Array(0..<10)),
            "SKK-JISYO.sample.utf-8": .disabled,
            "SKK-JISYO.dummy": .loading,
            "SKK-JISYO.error": .fail(DictionariesViewPreviewError.dummy)
        ]
        return DictionariesView(settingsViewModel: settings)
    }
}
