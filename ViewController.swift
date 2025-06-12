import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var sceneview: ARSCNView!
    var mainplanenode: SCNNode?
    var activehandle: SCNNode?
    var drawingimage: UIImage?
    var lasttouch: CGPoint?
    var isRotationModeEnabled: Bool = false
    var rotatebutton: UIButton?
    var isDimensionModeEnabled: Bool = false
    var dimensionbutton: UIButton?
    var isSnapToGridEnabled: Bool = false
    var snapgridbutton: UIButton?
    var pencolor: UIColor = .black
    var bgcolor: UIColor = .white

    override func viewDidLoad() {
        super.viewDidLoad()
        let gradientlayer = CAGradientLayer()
        gradientlayer.frame = view.bounds
        gradientlayer.colors = [
            UIColor(red: 0.2, green: 0.1, blue: 0.4, alpha: 0.3).cgColor,
            UIColor(red: 0.3, green: 0.1, blue: 0.5, alpha: 0.2).cgColor
        ]
        gradientlayer.startPoint = CGPoint(x: 0, y: 0)
        gradientlayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientlayer, at: 0)

        sceneview = ARSCNView(frame: view.bounds)
        sceneview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneview.backgroundColor = UIColor.clear
        view.addSubview(sceneview)

        sceneview.delegate = self
        sceneview.scene = SCNScene()
        sceneview.autoenablesDefaultLighting = true

        let btncontainer = UIView()
        btncontainer.translatesAutoresizingMaskIntoConstraints = false
        btncontainer.layer.cornerRadius = 12
        btncontainer.layer.masksToBounds = true

        let containergradient = CAGradientLayer()
        containergradient.colors = [
            UIColor(red: 0.3, green: 0.1, blue: 0.5, alpha: 0.9).cgColor,
            UIColor(red: 0.5, green: 0.2, blue: 0.7, alpha: 0.9).cgColor,
            UIColor(red: 0.7, green: 0.3, blue: 0.9, alpha: 0.9).cgColor
        ]
        containergradient.startPoint = CGPoint(x: 0, y: 0)
        containergradient.endPoint = CGPoint(x: 1, y: 1)
        containergradient.cornerRadius = 12
        btncontainer.layer.insertSublayer(containergradient, at: 0)

        btncontainer.layer.shadowColor = UIColor.black.cgColor
        btncontainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        btncontainer.layer.shadowRadius = 6
        btncontainer.layer.shadowOpacity = 0.25
        btncontainer.layer.masksToBounds = false

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.layoutMargins = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        stack.isLayoutMarginsRelativeArrangement = true

        func makebtn(title: String, selector: Selector, colors: [UIColor] = []) -> UIButton {
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = .boldSystemFont(ofSize: 11)
            btn.layer.cornerRadius = 6
            btn.layer.masksToBounds = true

            let gradientColors = colors.isEmpty ? [
                UIColor(red: 0.7, green: 0.3, blue: 0.9, alpha: 1.0),
                UIColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 1.0),
                UIColor(red: 0.4, green: 0.1, blue: 0.6, alpha: 1.0)
            ] : colors

            let btngradien = CAGradientLayer()
            btngradien.colors = gradientColors.map { $0.cgColor }
            btngradien.startPoint = CGPoint(x: 0, y: 0)
            btngradien.endPoint = CGPoint(x: 1, y: 1)
            btngradien.cornerRadius = 6
            btn.layer.insertSublayer(btngradien, at: 0)

            btn.layer.shadowColor = UIColor.black.cgColor
            btn.layer.shadowOffset = CGSize(width: 0, height: 1)
            btn.layer.shadowRadius = 1
            btn.layer.shadowOpacity = 0.2

            btn.widthAnchor.constraint(equalToConstant: 30).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 26).isActive = true
            btn.addTarget(self, action: selector, for: .touchUpInside)

            btn.addTarget(self, action: #selector(btnpress(_:)), for: .touchDown)
            btn.addTarget(self, action: #selector(btnrelease(_:)), for: [.touchUpInside, .touchUpOutside])

            return btn
        }

        func dropdownbtn(title: String, actions: [UIAction]) -> UIButton {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .boldSystemFont(ofSize: 11)
            button.layer.cornerRadius = 6
            button.layer.masksToBounds = true

            let btngradien = CAGradientLayer()
            btngradien.colors = [
                UIColor(red: 0.7, green: 0.3, blue: 0.9, alpha: 1.0).cgColor,
                UIColor(red: 0.5, green: 0.2, blue: 0.8, alpha: 1.0).cgColor,
                UIColor(red: 0.4, green: 0.1, blue: 0.6, alpha: 1.0).cgColor
            ]
            btngradien.startPoint = CGPoint(x: 0, y: 0)
            btngradien.endPoint = CGPoint(x: 1, y: 1)
            btngradien.cornerRadius = 6
            button.layer.insertSublayer(btngradien, at: 0)

            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor

            button.widthAnchor.constraint(equalToConstant: 30).isActive = true
            button.heightAnchor.constraint(equalToConstant: 26).isActive = true

            button.menu = UIMenu(title: "", children: actions)
            button.showsMenuAsPrimaryAction = true

            DispatchQueue.main.async {
                btngradien.frame = button.bounds
            }

            return button
        }

        let pencolorbtn = dropdownbtn(title: "P", actions: [
            UIAction(title: "Black", handler: { [weak self] _ in
                self?.pencolor = .black
                self?.updateColorButtonTitle(title: "P", color: .black)
            }),
            UIAction(title: "Red", handler: { [weak self] _ in
                self?.pencolor = .red
                self?.updateColorButtonTitle(title: "P", color: .red)
            }),
            UIAction(title: "Blue", handler: { [weak self] _ in
                self?.pencolor = .blue
                self?.updateColorButtonTitle(title: "P", color: .blue)
            }),
            UIAction(title: "Green", handler: { [weak self] _ in
                self?.pencolor = .green
                self?.updateColorButtonTitle(title: "P", color: .green)
            }),
            UIAction(title: "Purple", handler: { [weak self] _ in
                self?.pencolor = .purple
                self?.updateColorButtonTitle(title: "P", color: .purple)
            })
        ])

        let bgcolorbtn = dropdownbtn(title: "B", actions: [
            UIAction(title: "White", handler: { [weak self] _ in
                self?.bgcolor = .white
                self?.updateColorButtonTitle(title: "B", color: .white)
                self?.refreshdraw()
            }),
            UIAction(title: "Beige", handler: { [weak self] _ in
                self?.bgcolor = UIColor(red: 1.0, green: 0.97, blue: 0.88, alpha: 1.0)
                self?.updateColorButtonTitle(title: "B", color: UIColor(red: 1.0, green: 0.97, blue: 0.88, alpha: 1.0))
                self?.refreshdraw()
            }),
            UIAction(title: "Gray", handler: { [weak self] _ in
                self?.bgcolor = .lightGray
                self?.updateColorButtonTitle(title: "B", color: .lightGray)
                self?.refreshdraw()
            }),
            UIAction(title: "Dark", handler: { [weak self] _ in
                self?.bgcolor = .black
                self?.updateColorButtonTitle(title: "B", color: .black)
                self?.refreshdraw()
            })
        ])


        let rotatetoggle = makebtn(title: "R", selector: #selector(toggleRotation), colors: [
            UIColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 1.0),
            UIColor(red: 0.3, green: 0.1, blue: 0.7, alpha: 1.0),
            UIColor(red: 0.2, green: 0.0, blue: 0.6, alpha: 1.0)
        ])
        rotatebutton = rotatetoggle

        let toggledimension = makebtn(title: "D", selector: #selector(toggledimmode), colors: [
            UIColor(red: 0.6, green: 0.3, blue: 0.8, alpha: 1.0),
            UIColor(red: 0.5, green: 0.2, blue: 0.7, alpha: 1.0),
            UIColor(red: 0.4, green: 0.1, blue: 0.6, alpha: 1.0)
        ])
        dimensionbutton = toggledimension

        let addbtn = makebtn(title: "+", selector: #selector(addmanualplane), colors: [
            UIColor(red: 0.5, green: 0.2, blue: 0.9, alpha: 1.0),
            UIColor(red: 0.4, green: 0.1, blue: 0.8, alpha: 1.0),
            UIColor(red: 0.3, green: 0.0, blue: 0.7, alpha: 1.0)
        ])

        let deletebtn = makebtn(title: "X", selector: #selector(clearframes), colors: [
            UIColor(red: 0.7, green: 0.2, blue: 0.8, alpha: 1.0),
            UIColor(red: 0.6, green: 0.1, blue: 0.7, alpha: 1.0),
            UIColor(red: 0.5, green: 0.0, blue: 0.6, alpha: 1.0)
        ])

        let geminibtn = makebtn(title: "AI", selector: #selector(geminigrade), colors: [
            UIColor(red: 0.8, green: 0.3, blue: 0.9, alpha: 1.0),
            UIColor(red: 0.7, green: 0.2, blue: 0.8, alpha: 1.0),
            UIColor(red: 0.6, green: 0.1, blue: 0.7, alpha: 1.0)
        ])

        let clearbtn = makebtn(title: "C", selector: #selector(cleardraw), colors: [
            UIColor(red: 0.5, green: 0.3, blue: 0.7, alpha: 1.0),
            UIColor(red: 0.4, green: 0.2, blue: 0.6, alpha: 1.0),
            UIColor(red: 0.3, green: 0.1, blue: 0.5, alpha: 1.0)
        ])

        let togglesnap = makebtn(title: "G", selector: #selector(togglesnapgrid), colors: [
            UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1.0),
            UIColor(red: 0.5, green: 0.3, blue: 0.7, alpha: 1.0),
            UIColor(red: 0.4, green: 0.2, blue: 0.6, alpha: 1.0)
        ])
        snapgridbutton = togglesnap

        stack.addArrangedSubview(togglesnap)
        stack.addArrangedSubview(pencolorbtn)
        stack.addArrangedSubview(bgcolorbtn)

        [addbtn, deletebtn, geminibtn, clearbtn, rotatetoggle, toggledimension].forEach {
            stack.addArrangedSubview($0)
        }

        btncontainer.addSubview(stack)
        view.addSubview(btncontainer)

        DispatchQueue.main.async {
            containergradient.frame = btncontainer.bounds
        }

        NSLayoutConstraint.activate([
            btncontainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            btncontainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btncontainer.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 10),
            btncontainer.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            btncontainer.heightAnchor.constraint(equalToConstant: 38),

            stack.topAnchor.constraint(equalTo: btncontainer.topAnchor),
            stack.leadingAnchor.constraint(equalTo: btncontainer.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: btncontainer.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: btncontainer.bottomAnchor)
        ])

        let pangest = UIPanGestureRecognizer(target: self, action: #selector(handlepan(_:)))
        sceneview.addGestureRecognizer(pangest)

        sceneview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handletriple(_:))))
        sceneview.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handlelongpress(_:))))
    }

    func updateColorButtonTitle(title: String, color: UIColor) {
        print("\(title) color changed to: \(color)")
    }

    func refreshdraw() {
        guard let node = mainplanenode,
              let plane = node.childNode(withName: "plane", recursively: false)?.geometry as? SCNPlane else { return }
        drawingimage = blankDrawingImage()
        plane.materials.first?.diffuse.contents = drawingimage
    }


    @objc func btnpress(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc func togglesnapgrid() {
        isSnapToGridEnabled.toggle()
        updatebtn(snapgridbutton, isActive: isSnapToGridEnabled)

        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()

        print("Snap to Grid is now \(isSnapToGridEnabled ? "ON" : "OFF")")
    }

    @objc func btnrelease(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform.identity
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.subviews.forEach { subview in
            if let containerView = subview as? UIView {
                containerView.layer.sublayers?.forEach { layer in
                    if let gradientLayer = layer as? CAGradientLayer {
                        gradientLayer.frame = containerView.bounds
                    }
                }
            }
        }
    }

    @objc func handledims(_ gesture: UIPanGestureRecognizer) {
        let loc = gesture.location(in: sceneview)
        guard let parent = mainplanenode,
              let planenode = parent.childNode(withName: "plane", recursively: false),
              let plane = planenode.geometry as? SCNPlane else { return }

        switch gesture.state {
        case .began:
            let hits = sceneview.hitTest(loc, options: [SCNHitTestOption.categoryBitMask: 2])
            for r in hits where r.node.name?.contains("Edge") == true {
                activehandle = r.node
                return
            }
        case .changed:
            guard let handle = activehandle else { return }
            if let hit = sceneview.hitTest(loc, types: [.existingPlaneUsingExtent, .featurePoint]).first {
                let pos = hit.worldTransform.columns.3
                let local = planenode.convertPosition(SCNVector3(pos.x, pos.y, pos.z), from: nil)

                if handle.name?.contains("top") == true || handle.name?.contains("bottom") == true {
                    plane.height = max(0.1, CGFloat(abs(local.y)) * 2)
                }
                if handle.name?.contains("left") == true || handle.name?.contains("right") == true {
                    plane.width = max(0.1, CGFloat(abs(local.x)) * 2)
                }

                let w = Float(plane.width / 2)
                let h = Float(plane.height / 2)
                let z: Float = 0.01
                planenode.childNode(withName: "topEdge", recursively: false)?.position = SCNVector3(0, h, z)
                planenode.childNode(withName: "bottomEdge", recursively: false)?.position = SCNVector3(0, -h, z)
                planenode.childNode(withName: "leftEdge", recursively: false)?.position = SCNVector3(-w, 0, z)
                planenode.childNode(withName: "rightEdge", recursively: false)?.position = SCNVector3(w, 0, z)
            }
        case .ended, .cancelled:
            activehandle = nil
        default: break
        }
    }

    func updatebtn(_ button: UIButton?, isActive: Bool) {
        guard let button = button else { return }

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.allowUserInteraction]) {
            if isActive {
                button.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                button.layer.shadowRadius = 8
                button.layer.shadowOpacity = 0.8
                button.layer.shadowColor = UIColor.white.cgColor

                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.white.cgColor

                button.alpha = 1.0

                button.layer.shadowOffset = CGSize(width: 0, height: 0)
            } else {
                button.transform = CGAffineTransform.identity
                button.layer.shadowRadius = 1
                button.layer.shadowOpacity = 0.2
                button.layer.shadowColor = UIColor.black.cgColor

                button.layer.borderWidth = 0
                button.layer.borderColor = UIColor.clear.cgColor

                button.alpha = 0.9

                button.layer.shadowOffset = CGSize(width: 0, height: 1)
            }
        }
    }

    @objc func toggleRotation() {
        isRotationModeEnabled.toggle()

        if isRotationModeEnabled {
            isDimensionModeEnabled = false
            updatebtn(dimensionbutton, isActive: false)
        }

        updatebtn(rotatebutton, isActive: isRotationModeEnabled)

        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        print("Rotation Mode: \(isRotationModeEnabled ? "ON" : "OFF")")
    }

    @objc func clearframes() {
        sceneview.scene.rootNode.enumerateChildNodes { node, _ in
            if node.name == "surface" { node.removeFromParentNode() }
        }
        mainplanenode = nil
    }

    @objc func toggledimmode() {
        isDimensionModeEnabled.toggle()

        if isDimensionModeEnabled {
            isRotationModeEnabled = false
            updatebtn(rotatebutton, isActive: false)
        }

        updatebtn(dimensionbutton, isActive: isDimensionModeEnabled)

        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        print("Dimension Mode: \(isDimensionModeEnabled ? "ON" : "OFF")")
    }

    @objc func handlepan(_ gesture: UIPanGestureRecognizer) {
        if isRotationModeEnabled {
            planerotationplan(gesture)
        } else if isDimensionModeEnabled {
            handledims(gesture)
        } else {
            handledraw(gesture)
        }
    }

    @objc func geminigrade() {
        guard let img = drawingimage else { return }
        sendImageToGemini(image: img)
    }

    func sendImageToGemini(image: UIImage) {
        guard let imgdata = image.jpegData(compressionQuality: 0.8)?.base64EncodedString() else { return }

        let key = "redacted"
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(key)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": "Describe this sketch."],
                        ["inlineData": [
                            "mimeType": "image/jpeg",
                            "data": imgdata
                        ]]
                    ]
                ]
            ]
        ]


        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("err:", error)
                return
            }

            guard let data = data else {
                print("gemini blanked")
                return
            }

            print("\n", String(data: data, encoding: .utf8) ?? "deocdeerr")

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let candidates = json["candidates"] as? [[String: Any]],
                  let content = candidates.first?["content"] as? [String: Any],
                  let parts = content["parts"] as? [[String: Any]],
                  let text = parts.first?["text"] as? String else {
                print("JSON structure err")
                return
            }

            DispatchQueue.main.async {
                let alert = UIAlertController(title: "AI Interpretation", message: text, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }.resume()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        sceneview.session.run(config)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneview.session.pause()
    }

    func spawnCustomPlane(name: String, at position: SCNVector3, eulerAngles: SCNVector3 = SCNVector3Zero) -> SCNNode {
        let plane = SCNPlane(width: 0.75, height: 0.5)
        plane.cornerRadius = 0.05
        let mat = SCNMaterial()
        drawingimage = blankDrawingImage()
        mat.diffuse.contents = drawingimage
        mat.isDoubleSided = true
        plane.materials = [mat]

        let planenode = SCNNode(geometry: plane)
        planenode.name = "plane"

        let parentnode = SCNNode()
        parentnode.name = name
        parentnode.position = position
        parentnode.eulerAngles = eulerAngles
        parentnode.addChildNode(planenode)

        let handleradius: CGFloat = (0.015)*0.75
        let zOffset: Float = 0.01
        let edges: [(String, SCNVector3)] = [
            ("topEdge", SCNVector3(0, Float(plane.height / 2), zOffset)),
            ("bottomEdge", SCNVector3(0, -Float(plane.height / 2), zOffset)),
            ("leftEdge", SCNVector3(-Float(plane.width / 2), 0, zOffset)),
            ("rightEdge", SCNVector3(Float(plane.width / 2), 0, zOffset))
        ]

        for (name, pos) in edges {
            let h = SCNNode(geometry: SCNSphere(radius: handleradius))
            h.name = name
            h.position = pos
            h.categoryBitMask = 2
            h.geometry?.firstMaterial?.diffuse.contents = UIColor.black
            h.geometry?.firstMaterial?.lightingModel = .constant
            planenode.addChildNode(h)
        }

        sceneview.scene.rootNode.addChildNode(parentnode)
        return parentnode
    }

    func blankDrawingImage(size: CGSize = CGSize(width: 512, height: 512)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            bgcolor.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }


    func drawSmoothLine(on image: UIImage, from: CGPoint, to: CGPoint, control: CGPoint) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { ctx in
            image.draw(at: .zero)
            ctx.cgContext.setLineWidth(2)
            ctx.cgContext.setStrokeColor(pencolor.cgColor)
            ctx.cgContext.setLineCap(.round)
            ctx.cgContext.setLineJoin(.round)

            let path = UIBezierPath()
            path.move(to: from)
            path.addQuadCurve(to: to, controlPoint: control)
            path.stroke()
        }
    }

    func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }


    @objc func addmanualplane() {
        guard mainplanenode == nil else { return }
        var position: SCNVector3
        var rotation: SCNVector3

        if let hit = sceneview.hitTest(sceneview.center, types: [.existingPlaneUsingExtent]).first {
            let t = hit.worldTransform.columns.3
            position = SCNVector3(t.x, t.y, t.z)
            rotation = SCNVector3Zero
        } else if let frame = sceneview.session.currentFrame {
            let transform = frame.camera.transform
            let matrix = SCNMatrix4(transform)
            let dir = SCNVector3(-matrix.m31, -matrix.m32, -matrix.m33)
            let origin = SCNVector3(matrix.m41, matrix.m42, matrix.m43)
            let offset: Float = 0.5
            position = SCNVector3(origin.x + dir.x * offset, origin.y + dir.y * offset, origin.z + dir.z * offset)
            rotation = SCNVector3(0, frame.camera.eulerAngles.y + .pi, 0)
        } else {
            return
        }
        mainplanenode = spawnCustomPlane(name: "surface", at: position, eulerAngles: rotation)
    }

    @objc func cleardraw() {
        guard let node = mainplanenode,
              let plane = node.childNode(withName: "plane", recursively: false)?.geometry as? SCNPlane else { return }
        drawingimage = blankDrawingImage()
        plane.materials.first?.diffuse.contents = drawingimage
    }

    @objc func handledraw(_ gesture: UIPanGestureRecognizer) {
        guard let node = mainplanenode,
              let planeNode = node.childNode(withName: "plane", recursively: false),
              let plane = planeNode.geometry as? SCNPlane else { return }

        if drawingimage == nil {
            drawingimage = blankDrawingImage()
            plane.materials.first?.diffuse.contents = drawingimage
        }

        guard let img = drawingimage else { return }

        let loc = gesture.location(in: sceneview)
        let hits = sceneview.hitTest(loc, options: nil)
        guard let result = hits.first(where: { $0.node.name == "plane" }) else { return }

        let uv = result.textureCoordinates(withMappingChannel: 0)
        var point = CGPoint(x: CGFloat(uv.x) * img.size.width, y: (1 - CGFloat(uv.y)) * img.size.height)
        if isSnapToGridEnabled {
            let gridSize: CGFloat = 32
            point.x = round(point.x / gridSize) * gridSize
            point.y = round(point.y / gridSize) * gridSize
        }

        switch gesture.state {
        case .began:
            lasttouch = point
        case .changed:
            guard let last = lasttouch else { return }
            let mid = midPoint(p1: last, p2: point)
            drawingimage = drawSmoothLine(on: img, from: last, to: point, control: mid)
            lasttouch = point
            plane.materials.first?.diffuse.contents = drawingimage
        case .ended, .cancelled:
            lasttouch = nil
        default: break
        }
    }

    func drawLine(on image: UIImage, from: CGPoint, to: CGPoint) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { ctx in
            image.draw(at: .zero)
            ctx.cgContext.setLineWidth(4)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineCap(.round)
            ctx.cgContext.move(to: from)
            ctx.cgContext.addLine(to: to)
            ctx.cgContext.strokePath()
        }
    }

    @objc func handletriple(_ gesture: UITapGestureRecognizer) {
        guard let node = mainplanenode else { return }
        node.runAction(.sequence([
            .group([.fadeOut(duration: 0.5), .scale(to: 0, duration: 0.5)]),
            .removeFromParentNode()
        ]))
        mainplanenode = nil
    }

    @objc func planerotationplan(_ gesture: UIPanGestureRecognizer) {
        guard let node = mainplanenode else { return }
        let translation = gesture.translation(in: sceneview)
        switch gesture.state {
        case .began, .changed:
            let dx = Float(translation.x)
            let dy = Float(translation.y)
            node.eulerAngles.y += -dx / 300
            node.eulerAngles.x += -dy / 300
            gesture.setTranslation(.zero, in: sceneview)
        default: break
        }
    }

    @objc func handlelongpress(_ gesture: UILongPressGestureRecognizer) {
        let loc = gesture.location(in: sceneview)
        guard let parent = mainplanenode,
              let planeNode = parent.childNode(withName: "plane", recursively: false),
              let plane = planeNode.geometry as? SCNPlane else { return }

        switch gesture.state {
        case .began:
            let hits = sceneview.hitTest(loc, options: [SCNHitTestOption.categoryBitMask: 2])
            for r in hits where r.node.name?.contains("Edge") == true {
                activehandle = r.node
                return
            }
        case .changed:
            guard let handle = activehandle else { return }
            if let hit = sceneview.hitTest(loc, types: [.existingPlaneUsingExtent, .featurePoint]).first {
                let pos = hit.worldTransform.columns.3
                let local = planeNode.convertPosition(SCNVector3(pos.x, pos.y, pos.z), from: nil)

                if handle.name?.contains("top") == true || handle.name?.contains("bottom") == true {
                    plane.height = max(0.1, CGFloat(abs(local.y)) * 2)
                }
                if handle.name?.contains("left") == true || handle.name?.contains("right") == true {
                    plane.width = max(0.1, CGFloat(abs(local.x)) * 2)
                }

                let w = Float(plane.width / 2)
                let h = Float(plane.height / 2)
                let z: Float = 0.01
                planeNode.childNode(withName: "topEdge", recursively: false)?.position = SCNVector3(0, h, z)
                planeNode.childNode(withName: "bottomEdge", recursively: false)?.position = SCNVector3(0, -h, z)
                planeNode.childNode(withName: "leftEdge", recursively: false)?.position = SCNVector3(-w, 0, z)
                planeNode.childNode(withName: "rightEdge", recursively: false)?.position = SCNVector3(w, 0, z)
            }
        case .ended, .cancelled:
            activehandle = nil
        default: break
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard mainplanenode == nil else { return }

        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let center = planeAnchor.center
        let position = SCNVector3(center.x, 0, center.z)
        let euler = SCNVector3(-Float.pi / 2, 0, 0)

        let smartNode = spawnCustomPlane(name: "surface", at: position, eulerAngles: euler)
        node.addChildNode(smartNode)
        mainplanenode = smartNode
    }
}
