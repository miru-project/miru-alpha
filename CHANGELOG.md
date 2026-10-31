# Changelog

All notable changes to this project will be documented in this file.


## 2.0.2-alpha - 2026-10-31

### Bug Fixes
- Enhance play button  and thunmnail zooming (mobile/detail)
- Add download in quich access and ability to remove watch entry in continue watch (mobile/home)
- Remove `marionette` in release mode
- Windows.build error
- Change ffmpeg binary  source (linux)
- Disable software rendering  + add http header for request (subtitles)
- Previewing only works on debug mode

### Features
- Add error status onto broken extension (search)
- Better extension UI and search UI (mobile)
- Screen brightness (linux)
- DLNA casting via in-process ffmpeg engine, player request parity (cast)
- Render the desktop app inside a 412x915 phone frame by default (app)
- Failure taxonomy, error/loading player overlays and tabbed content body (watch)
- Use cliff to generate changelog (CI)

### Other Changes
- Clean up i18n
- Remove duplicated download info

### Refactor
- Home ,detail page (mobile)

### Tests
- Move widget tests into per-feature ui directories
## 2.0.1-alpha+100002 - 2026-10-15

### Bug Fixes
- Drive pubspec from the tag instead of guarding against it (ci)
## 2.0.1-alpha1 - 2026-10-15

### CI
- Automate versioning and changelog generation (release)
## 2.0.1-alpha - 2026-10-15

### Bug Fixes
- Migrate from flutter_in_app_webview to webview_all (CI)
- Shrink-wrap desktop detail action buttons (ui)
## 2.0.0-alpha1 - 2026-05-02

### Bug Fixes
- Quickjs evaluation issue
- Remove unnecessary folder and executable
- Add CMakeLists.txt for miru_core with build scripts for Linux
- Linux  cmake
- Remove mecessary file
- Change location of .gitattribute
- Build
- Build error on windows machine
- Try decrease size of APK
- Update update `upload-artifact`
- Linux gtk build
- Linux build
- Ububtu linux build
- Update Linux build to use Ubuntu 22.04 and comment out WebKit installation
- Add libsoup-3.0 to dependencies in CI workflow
- Add `alsa`
- Linux CI
- Update ubuntu
- Linux build
- Linux artifacts
- Attempt to decrease ffmpeg lib size in linux
- Linux cmake and video player ui
- Attempt windows build
- Build android
- Build gomobile on workflow
- Fetch submodule(miru_core) before build
- Gombile directory
- Create AAR dir before built by gomobile
- Improve mobile UI
- Dependencies issue on linux build
- Integrate polling mechanism for extension metadata and remove unused extension service
- Refactor UI components and remove unused widgets
- Change default ip address to port 3000
- Mobile provider issues
- Upgrade flutter version (CI)
- Upgrade android target api of gomobile (CI)
- Mobile  page  translation color theme
- Download issue for mp4 and torrent
- Add wakelock and fix json parsing on extension watch
- Use the same path method on windows  with libmiru_core
- Attempt remove permission handler to avoid crash in some device (window)
- Update dependncies and fix some render overflow
- Android init error
- CI build for linux and android
- CI
- Linux build (CI)
- Linux build (CI)
- Linux Build (CI)
- Cmake build for windows
- Add mingw dependencies  into built zip (windows)
- Build error on cmake and split seperate pllatform when building miru core (linux)
- Translations and build error
- Windows build (CI)
- Linux build (CI)
- Remove docs submodule

### CI
- Fix build error

### Chore
- Remove GetX

### Features
- Add macOS window manipulation functionality
- Theme customization
- Video player
- Basic video player
- Video player gesture
- Init manga reader
- Init search page
- Filter history by time and type
- Add search in Latest
- Favorite management
- Android webview support
- Init android video converting
- Init Donwload
- Support miru_core add download ui on linux and android
- Build `ffmpeg_merge` and `miru_core` library
- Fix building error on linux and android
- Add miru_core submodule with initial commit reference
- Add Setting extesnion Page
- Init search page and update submodule
- Refactor network requests and improve UI components
- Init Latest in `forui`
- Init detail
- Init watch
- Add CI workflow for development builds
- Update flutter ` 3.35.4`
- Remove objectbox use miru_core as database instead
- Attempt to build android
- Sign  android apk
- Init setting UI of mobile  layout
- Implement setting groups and improve layout handling for mobile and desktop
- Implement desktop and mobile search pages
- Enhance search functionality and improve loading behavior in search grid view
- Implement webview functionality for desktop and mobile, enhance image widget to support data URLs
- Add more settings for mobile layout
- Add detail page for mobile
- Enhance video player UI with new mobile controls and settings, improve license page, and refine episode selection on detail pages.
- Refactor reader and player components into a new watch directory, introduce new reader , and update core dependencies.
- Rework manga reader with multiple reading modes and zoom, update app icons, and address keyboard overlap.
- Add progress in readme.md
- Implement new application launcher icons for Android and Windows.
- Introduce torrent support for `ExtensionBangumiWatch` and `VideoPlayerPage`.
- Implement gRPC for core service communication and update data models.
- Enhance favorite management with new UI components and logic, introduce a library page, and remove unused bluetooth server utility.
- Mobile libarary overview
- Add animated icon from bottom Navbar
- Save the detail
- Novel reader for mobile
- Init download function and gpc stream for getting extxension metadata
- Refactor HeartButton to be stateless, integrate favorite state management into detail page, and implement platform-specific layouts for the favorite page.
- Enhance desktop UI for search and detail pages, refactor search filter, and add navigation to continue watching and favorites.
- Add single image view mobile detail
- Introduce desktop video player widget and episode card, enhance player settings, and improve search page UX.
- Implement global search functionality for desktop and fix video player volume and brightness.
- Refactor library page navigation, recreate FTab
- Init mobile global search
- Enhance desktop detail experience
- Add episode list reversal to mobile detail page, improve episode group selection, and refine ExtensionType resolution.
- Use the local downloaded content if the resource has existed (video )
- Introduce a dedicated favorite page provider with filtering capabilities and add a novel reader side sheet for desktop.
- Add episode refresh button and update episode model with update and description fields; refactor ExtensionType to 'all' and remove unused core utilities.
- Migrate sheet implementation from `snapping_sheet_2` to `smooth_sheets` and update related dependencies.
- Attempt capture logs into file systems
- Relocate error logs to the app support directory, add alsa dependencies to the build workflow
- Init translation
- Init proxy on desktop
- Init support for  mobile proxy
- Introduce platform-specific error UI and initial theme selection, and improve proxy settings persistence and validation.
- Implement extension settings management with a dedicated UI and new API endpoints. (desktop)
- Init search filter (desktop)
- Init search filter (mobile)
- Anilist support
- Init TMDB
- Implement  mirror selection for watch and restructure provider code base
- Add update filter for extensions, optimize image viewers, and improve UI component layout
- Init  mobile inline code editor
- Add mobile tracking and some UI improvment for anilist and tracking
- Enhance dektop and mobile tracking
- Init support devtool
- Add alpha release ci

### Other Changes
- Add macos_window_utils dependency for macOS support
- Update button size in home and search pages
- Beautify detail page
- Use go router instead of getx router
- Update gradle to 8.10
- Add .gitattributes to mark ffmpeg_merge files as vendored
- Update miru core
- Remove uncessary package
- Use `riverpod generator`  on most provider
- Update CI workflow and README for environment variable usage and dependency versions
- Change android app name and id
- Update pubspec dependencies to latest versions
- Update subproject commit reference in miru-core
- Reorganize the project structure and add mobile detail page initially
- Upgrade dependices and flutter version (`3.28.1`)
- Change windows ffmpeg lib source
- Remove unused imports from mobile detail page and player header.
- Upgrade forui to 0.17.0,
- Make  `main_provider` dart generated
- Add network option to fasthttp and chnage generated gprc  directory
- Update flutter version and dependencies
- Update flutter (to 3.14) and forui (to 0.18)
- Use json_serialize on repolist
- Diagnose ffmpeg lib
- Attempt to print out ffmpeg deps issue verbosly
- Change app name and package name
- Add more  legal info
- Update deps
- Update documentation and project metadata while initializing wiki git hooks

### Refactor
- Watch page
- Linux cmake
- Reorganize project structure
- Streamline network request handling and improve search functionality
- Rename MiruGridTile to MiruDesktopGridTile and introduce MiruMobileTile for better platform differentiation
- Video player provider and related UI components
- Refactor the project structure
- Split manga reader settings into general and page-specific components and improve page navigation.
- Refactoring the player UI and updating dependencies.
- Move favorite page, update home exports, refactor MiruScaffold for separate mobile/desktop bodies, and remove unnecessary logging.
- Unify favorite page layout, enhance favorite and history management, and update CI/CD dependencies.
- Partially  mobile detail and animated icon
- Initialize Miru Core isolate with `RootIsolateToken` and improve FFmpeg DLL path handling and error logging.
- Reorganzie i18n json structure

### Chroe
- Update deps

### Init
- Change to forui
