# Camera package (scraped)

(Extracted from https://pub.dev/packages/camera)

- Initialization: call `availableCameras()` to list cameras, create `CameraController` with chosen camera and `ResolutionPreset`.
- Lifecycle: manage controller lifecycle in `initState`, `dispose`, and `didChangeAppLifecycleState` if needed.
- Example: initialize controller, call `controller.initialize()`, use `CameraPreview(controller)` to display preview, dispose controller on `dispose()`.

(Full extracted content saved.)