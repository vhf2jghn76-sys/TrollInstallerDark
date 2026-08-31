# دليل المشتركين الجدد في TrollInstallerDark

## نظرة عامة

TrollInstallerDark هو تطبيق iOS مبني بواجهة SwiftUI مع طبقات منخفضة المستوى مكتوبة بـ C وObjective-C. يهدف المشروع إلى تثبيت TrollStore على الأجهزة المدعومة، وهو مبني على TrollInstallerX مع إضافة تكامل DarkSword.

> ملاحظة: قبل تعديل نطاقات الدعم أو الرسائل المعروضة للمستخدم، راجع README وواجهة التطبيق ومنطق `Device` معاً، لأن هذه الأماكن قد تعرض أو تحسب نطاقات دعم مختلفة.

## الهيكل العام

```text
.
├── README.md
├── build.sh
├── Resources/
│   ├── Icon.png
│   └── ents.plist
├── .github/workflows/
│   └── build.yml
├── TrollInstallerX.xcodeproj/
└── TrollInstallerX/
    ├── TrollInstallerXApp.swift
    ├── TrollInstallerX-Bridging-Header.h
    ├── UI/
    ├── Models/
    ├── Installer/
    ├── Exploitation/
    ├── External/
    ├── Resources/
    └── patchfinder/
```

### `TrollInstallerXApp.swift`

نقطة الدخول لتطبيق SwiftUI. يقوم بفتح `MainView` داخل `WindowGroup` ويجبر التطبيق على المظهر الداكن.

### `UI/`

تحتوي شاشات SwiftUI. أهم ملف هو `MainView.swift` لأنه يربط واجهة المستخدم بمسار التثبيت:

- يعرض اسم التطبيق وزر التثبيت.
- يعطل الواجهة عندما يكون الجهاز غير مدعوم.
- يعرض سجلات التثبيت أثناء التنفيذ.
- يفتح النوافذ المنبثقة الخاصة بالإعدادات والاعتمادات وOTA وMacDirtyCow واختيار persistence helper.
- يقرر عند بدء التثبيت هل يستخدم `doDirectInstall` أو `doIndirectInstall`.

### `Models/`

يحتوي نماذج وحالة التطبيق:

- `Device.swift`: يحدد إصدار iOS، المعمارية، عائلة المعالج، ودعم الجهاز ومسار التثبيت.
- `Exploit.swift`: يعرّف الاستغلالات ونطاقات الإصدارات المدعومة ودوال التهيئة وإلغاء التهيئة.
- `InstalledApp.swift`: يعرّف التطبيقات المرشحة لاستخدامها كـ persistence helper.
- `Logger.swift`: يوفّر نظام سجلات بسيطاً لعرض تقدم التثبيت داخل الواجهة.
- `Defaults.swift`: يغلّف `UserDefaults` الخاص بإعدادات التطبيق.
- `Version.swift`: يستخدم لمقارنة إصدارات iOS وTrollStore.

### `Installer/`

يحتوي منطق التثبيت عالي المستوى وجزءاً من الواجهات منخفضة المستوى:

- `Installation.swift`: المسار الأساسي للتثبيت، ويشمل اختيار الاستغلال، جلب kernelcache، تشغيل patchfinder، رفع الصلاحيات، تثبيت TrollStore، وتثبيت persistence helper.
- `Extract.swift`: استخراج `TrollStore.tar` ونسخ الملفات المساعدة.
- `Update.swift`: التحقق من أحدث إصدار TrollStore وتنزيله عند الحاجة.
- ملفات `.h/.m/.c` الأخرى: تنفيذ دوال C/Objective-C التي تستدعيها Swift عبر bridging header.

### `Exploitation/`

يحتوي تكامل الاستغلالات والبدائل منخفضة المستوى:

- `darksword/`: تكامل DarkSword.
- `dmaFail/`: PPL bypass.
- `kfd/`: استغلالات kfd.
- `MacDirtyCow/`: مسارات MacDirtyCow والـ unsandbox المساعد.
- `libjailbreak/`: primitives ووظائف kernel/physical read-write مساعدة.

### `patchfinder/`

يحتوي كود patchfinder المستخدم لاستخراج معلومات kernel المطلوبة قبل تشغيل مسارات الامتيازات.

### `External/`

يحتوي مكتبات خارجية headers/libs مثل `libgrabkernel2` ومكتبات ثابتة أو ديناميكية يستخدمها المشروع.

### `Resources/`

يوجد مجلدان مهمان:

- `Resources/` في جذر المشروع: يحتوي الأيقونة وملف entitlements المستخدم في التغليف.
- `TrollInstallerX/Resources/`: يحتوي `TrollStore.tar` المضمن داخل التطبيق.

### `.github/workflows/build.yml` و`build.sh`

كلاهما يبني التطبيق بدون code signing من Xcode، ثم يستخدم `ldid` للتوقيع شبه الصوري، وبعدها ينشئ ملف IPA.

## مسار التشغيل الأساسي

1. يفتح التطبيق `MainView`.
2. يتم إنشاء `Device` لفحص الجهاز والإصدار والمعمارية.
3. إذا كان الجهاز مدعوماً، يسمح زر التثبيت بالبدء.
4. عند الضغط على زر التثبيت، تختار الواجهة أحد المسارين:
   - `doDirectInstall` إذا كان الجهاز يدعم التثبيت المباشر.
   - `doIndirectInstall` إذا كان يحتاج مسار persistence-helper غير مباشر.
5. يتم اختيار exploit من `selectExploit` حسب الإعدادات أو الافتراضي.
6. يحصل التطبيق على kernelcache من bundle أو من النظام عبر MacDirtyCow أو بالتنزيل.
7. يشغل patchfinder لاستخراج معلومات kernel.
8. يشغل kernel exploit ثم خطوات ما بعد الاستغلال.
9. على بعض الأجهزة، يشغل PPL bypass ويبني physical read/write primitive.
10. يتم unsandbox ورفع الصلاحيات.
11. يتم استخراج TrollStore وتثبيته.
12. يختار المستخدم persistence helper ويتم تثبيته.
13. تنظف الملفات المؤقتة، وقد يحدث respring في المسار غير المباشر.

## أمور مهمة قبل تعديل الكود

### لا تعدل نطاقات الدعم في مكان واحد فقط

إذا تغير دعم إصدار iOS أو عائلة CPU، راجع على الأقل:

- `README.md`
- `TrollInstallerX/UI/MainView.swift`
- `TrollInstallerX/Models/Device.swift`
- `TrollInstallerX/Models/Exploit.swift`

### انتبه إلى الجسر بين Swift وC

أي دالة C أو Objective-C تحتاجها Swift يجب أن تكون مكشوفة عبر `TrollInstallerX-Bridging-Header.h`. تغيير أسماء الدوال أو توقيعاتها بدون تحديث هذا الملف سيؤدي إلى أخطاء build.

### مسار التثبيت حساس جداً للحالة

العمليات تعتمد على ملفات مؤقتة، صلاحيات، حالة sandbox، kernelcache، واختيار المستخدم للـ persistence helper. عند إصلاح مشكلة، اقرأ رسائل `Logger.log` أولاً لأنها تحدد المرحلة التي فشلت.

### لا تفترض أن الاختبار على Simulator كافٍ

Simulator مفيد لفحص أجزاء من SwiftUI، لكنه لا يستطيع اختبار الاستغلالات، patchfinder الحقيقي، رفع الصلاحيات، remount، أو تثبيت TrollStore.

### راجع الملفات الثنائية بحذر

المشروع يحتوي مكتبات خارجية وملف `TrollStore.tar`. لا تستبدل الملفات الثنائية أو الموارد الحساسة إلا إذا كان مصدرها معروفاً وتم التحقق منها.

## ما الذي ينبغي تعلمه بعد ذلك؟

### للمساهمين في الواجهة

- SwiftUI basics: `View`, `@State`, `@ObservedObject`, `Binding`.
- إدارة النوافذ المنبثقة والحالات المتداخلة.
- التعامل مع async tasks في SwiftUI.
- تصميم واجهات تعرض خطوات طويلة وفاشلة جزئياً بطريقة واضحة.

### للمساهمين في منطق التثبيت

- `FileManager` ومسارات sandbox في iOS.
- بنية تطبيقات iOS وIPA وPayload.
- entitlements و`ldid`.
- آلية persistence helper في TrollStore.
- الفرق بين direct install وindirect install.

### للمساهمين في الطبقة منخفضة المستوى

- Swift bridging header وكيفية استدعاء C من Swift.
- أساسيات Mach, IOKit, sysctl, vnode, وkernelcache.
- فكرة patchfinding ولماذا يحتاجها المشروع.
- lifecycle لأي exploit: تهيئة، استخدام primitives، تنظيف.
- الفروقات بين arm64 وarm64e وPPL bypass.

## نقاط بداية مقترحة

- اقرأ `README.md` لفهم الهدف وطريقة البناء.
- اقرأ `TrollInstallerX/TrollInstallerXApp.swift` و`TrollInstallerX/UI/MainView.swift` لفهم واجهة البداية.
- اقرأ `TrollInstallerX/Models/Device.swift` لفهم منطق الدعم.
- اقرأ `TrollInstallerX/Models/Exploit.swift` لفهم جدول الاستغلالات.
- اقرأ `TrollInstallerX/Installer/Installation.swift` لفهم مسار التثبيت الكامل.
- اقرأ `TrollInstallerX/TrollInstallerX-Bridging-Header.h` قبل تعديل أي كود C/Objective-C مستدعى من Swift.

## أوامر مفيدة

```bash
# عرض حالة git
git status --short

# استعراض الملفات المهمة بدون مسح عميق بطيء
find . -maxdepth 2 -type f | sort

# بناء IPA على macOS مع Xcode وldid
./build.sh
```
