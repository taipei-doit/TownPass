import 'dart:ui';

// MARK: - Constants Grouping
//
// 此區塊將相關的應用程式常數歸類到抽象類別中，
// 以提升程式碼結構、可讀性及可維護性。
// 原有的頂層常數現在被別名到這些新的結構化常數上，
// 以確保向下兼容性，不改變既有的 API 介面。

/// 應用程式主工具列相關的常數。
abstract class TPToolbarConstants {
  static const double height = 56;
  static const double bottomHeight = 46;
}

/// 應用程式中郵件操作相關的常數。
abstract class TPMailConstants {
  static const String launchScheme = 'mailto';
  static const String address = 'CodeFestTaipei@gov.taipei';
}

/// 應用程式自定義開關（Switch）UI 元件的常數。
abstract class TPSwitchConstants {
  static const Size size = Size(48, 32);
}

/// 應用程式中使用的通用數學常數。
abstract class AppMathConstants {
  static const double goldenRatio = 1.618;
}

// MARK: - 回溯兼容性與公共 API
//
// 這些是原始的頂層常數定義。
// 它們被別名到上方新結構化的常數，以維持與現有程式碼的兼容性，
// 確保既有的匯入和使用不會受到功能行為或 API 輸出入的改變。
// 新的程式碼建議直接使用其所屬類別中的常數 (例如: TPToolbarConstants.height)。

const double kTPToolbarHeight = TPToolbarConstants.height;

const double kTPToolbarBottomHeight = TPToolbarConstants.bottomHeight;

const String tpLaunchMailScheme = TPMailConstants.launchScheme;

const String tpMailAddress = TPMailConstants.address;

const Size tpSwitchSize = TPSwitchConstants.size;

const double goldenRatio = AppMathConstants.goldenRatio;