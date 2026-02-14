import SwiftUI

struct AddServerView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    var editingServer: ServerConfig?
    
    @State private var name = ""
    @State private var address = ""
    @State private var port = "443"
    @State private var protocolType: ProtocolType = .vmess
    @State private var uuid = ""
    
    // VMess specific
    @State private var alterId = "0"
    @State private var vmessSecurity = "auto"
    
    // VLESS specific
    @State private var vlessEncryption = "none"
    @State private var flow = ""
    
    // Transport
    @State private var network = "tcp"
    @State private var security = "none"
    
    // TLS
    @State private var sni = ""
    @State private var fingerprint = "chrome"
    @State private var alpn = ""
    @State private var allowInsecure = false
    
    // WebSocket
    @State private var wsPath = "/"
    @State private var wsHost = ""
    
    // gRPC
    @State private var grpcServiceName = ""
    @State private var grpcMode = "gun"
    
    // Reality
    @State private var realityPublicKey = ""
    @State private var realityShortId = ""
    @State private var realitySpiderX = ""
    
    var isEditing: Bool { editingServer != nil }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(isEditing ? "Edit Server" : "Add Server")
                    .font(.headline)
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape)
            }
            .padding()
            
            Divider()
            
            // Form
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Basic settings
                    GroupBox("Basic Settings") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Name")
                                    .frame(width: 100, alignment: .trailing)
                                TextField("Server name", text: $name)
                            }
                            
                            HStack {
                                Text("Address")
                                    .frame(width: 100, alignment: .trailing)
                                TextField("server.example.com", text: $address)
                            }
                            
                            HStack {
                                Text("Port")
                                    .frame(width: 100, alignment: .trailing)
                                TextField("443", text: $port)
                                    .frame(width: 100)
                            }
                            
                            HStack {
                                Text("Protocol")
                                    .frame(width: 100, alignment: .trailing)
                                Picker("", selection: $protocolType) {
                                    Text("VMess").tag(ProtocolType.vmess)
                                    Text("VLESS").tag(ProtocolType.vless)
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 200)
                            }
                            
                            HStack {
                                Text("UUID")
                                    .frame(width: 100, alignment: .trailing)
                                TextField("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", text: $uuid)
                                Button("Generate") {
                                    uuid = UUID().uuidString.lowercased()
                                }
                            }
                        }
                        .padding(8)
                    }
                    
                    // Protocol specific settings
                    if protocolType == .vmess {
                        GroupBox("VMess Settings") {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Alter ID")
                                        .frame(width: 100, alignment: .trailing)
                                    TextField("0", text: $alterId)
                                        .frame(width: 100)
                                }
                                
                                HStack {
                                    Text("Security")
                                        .frame(width: 100, alignment: .trailing)
                                    Picker("", selection: $vmessSecurity) {
                                        Text("auto").tag("auto")
                                        Text("aes-128-gcm").tag("aes-128-gcm")
                                        Text("chacha20-poly1305").tag("chacha20-poly1305")
                                        Text("none").tag("none")
                                        Text("zero").tag("zero")
                                    }
                                    .frame(width: 180)
                                }
                            }
                            .padding(8)
                        }
                    } else {
                        GroupBox("VLESS Settings") {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Encryption")
                                        .frame(width: 100, alignment: .trailing)
                                    Picker("", selection: $vlessEncryption) {
                                        Text("none").tag("none")
                                    }
                                    .frame(width: 180)
                                }
                                
                                HStack {
                                    Text("Flow")
                                        .frame(width: 100, alignment: .trailing)
                                    Picker("", selection: $flow) {
                                        Text("(none)").tag("")
                                        Text("xtls-rprx-vision").tag("xtls-rprx-vision")
                                    }
                                    .frame(width: 180)
                                }
                            }
                            .padding(8)
                        }
                    }
                    
                    // Transport settings
                    GroupBox("Transport") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Network")
                                    .frame(width: 100, alignment: .trailing)
                                Picker("", selection: $network) {
                                    Text("tcp").tag("tcp")
                                    Text("ws").tag("ws")
                                    Text("grpc").tag("grpc")
                                    Text("http").tag("http")
                                    Text("quic").tag("quic")
                                }
                                .frame(width: 180)
                            }
                            
                            HStack {
                                Text("Security")
                                    .frame(width: 100, alignment: .trailing)
                                Picker("", selection: $security) {
                                    Text("none").tag("none")
                                    Text("tls").tag("tls")
                                    Text("reality").tag("reality")
                                }
                                .frame(width: 180)
                            }
                        }
                        .padding(8)
                    }
                    
                    // TLS settings
                    if security == "tls" {
                        GroupBox("TLS Settings") {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("SNI")
                                        .frame(width: 100, alignment: .trailing)
                                    TextField("Server name", text: $sni)
                                }
                                
                                HStack {
                                    Text("Fingerprint")
                                        .frame(width: 100, alignment: .trailing)
                                    Picker("", selection: $fingerprint) {
                                        Text("chrome").tag("chrome")
                                        Text("firefox").tag("firefox")
                                        Text("safari").tag("safari")
                                        Text("randomized").tag("randomized")
                                    }
                                    .frame(width: 180)
                                }
                                
                                HStack {
                                    Text("ALPN")
                                        .frame(width: 100, alignment: .trailing)
                                    TextField("h2,http/1.1", text: $alpn)
                                }
                                
                                HStack {
                                    Text("")
                                        .frame(width: 100, alignment: .trailing)
                                    Toggle("Allow Insecure", isOn: $allowInsecure)
                                }
                            }
                            .padding(8)
                        }
                    }
                    
                    // Reality settings
                    if security == "reality" {
                        GroupBox("Reality Settings") {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("SNI")
                                        .frame(width: 100, alignment: .trailing)
                                    TextField("Server name", text: $sni)
                                }
                                
                                HStack {
                                    Text("Fingerprint")
                                        .frame(width: 100, alignment: .trailing)
                                    Picker("", selection: $fingerprint) {
                                        Text("chrome").tag("chrome")
                                        Text("firefox").tag("firefox")
                                        Text("safari").tag("safari")
                                    }
                                    .frame(width: 180)
                                }
                                
                                HStack {
                                    Text("Public Key")
                                        .frame(width: 100, alignment: .trailing)
                                    TextField("Reality public key", text: $realityPublicKey)
                                }
                                
                                HStack {
                                    Text("Short ID")
                                        .frame(width: 100, alignment: .trailing)
                                    TextField("Short ID", text: $realityShortId)
                                }
                                
                                HStack {
                                    Text("SpiderX")
                                        .frame(width: 100, alignment: .trailing)
                                    TextField("/", text: $realitySpiderX)
                                }
                            }
                            .padding(8)
                        }
                    }
                    
                    // WebSocket settings
                    if network == "ws" {
                        GroupBox("WebSocket Settings") {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Path")
                                        .frame(width: 100, alignment: .trailing)
                                    TextField("/", text: $wsPath)
                                }
                                
                                HStack {
                                    Text("Host")
                                        .frame(width: 100, alignment: .trailing)
                                    TextField("Host header", text: $wsHost)
                                }
                            }
                            .padding(8)
                        }
                    }
                    
                    // gRPC settings
                    if network == "grpc" {
                        GroupBox("gRPC Settings") {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Service Name")
                                        .frame(width: 100, alignment: .trailing)
                                    TextField("Service name", text: $grpcServiceName)
                                }
                                
                                HStack {
                                    Text("Mode")
                                        .frame(width: 100, alignment: .trailing)
                                    Picker("", selection: $grpcMode) {
                                        Text("gun").tag("gun")
                                        Text("multi").tag("multi")
                                    }
                                    .frame(width: 180)
                                }
                            }
                            .padding(8)
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Footer buttons
            HStack {
                Spacer()
                Button("Save") {
                    saveServer()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return)
                .disabled(!isValid)
            }
            .padding()
        }
        .frame(width: 550, height: 600)
        .onAppear {
            if let server = editingServer {
                loadServer(server)
            }
        }
    }
    
    var isValid: Bool {
        !name.isEmpty && !address.isEmpty && !port.isEmpty && !uuid.isEmpty
    }
    
    func loadServer(_ server: ServerConfig) {
        name = server.name
        address = server.address
        port = String(server.port)
        protocolType = server.type
        uuid = server.uuid
        alterId = String(server.alterId ?? 0)
        vmessSecurity = server.encryption ?? "auto"
        vlessEncryption = server.encryption ?? "none"
        flow = server.flow ?? ""
        network = server.network ?? "tcp"
        security = server.security ?? "none"
        sni = server.sni ?? ""
        fingerprint = server.fingerprint ?? "chrome"
        alpn = server.alpn ?? ""
        allowInsecure = server.allowInsecure ?? false
        wsPath = server.wsPath ?? "/"
        wsHost = server.wsHost ?? ""
        grpcServiceName = server.grpcServiceName ?? ""
        grpcMode = server.grpcMode ?? "gun"
        realityPublicKey = server.realityPublicKey ?? ""
        realityShortId = server.realityShortId ?? ""
        realitySpiderX = server.realitySpiderX ?? ""
    }
    
    func saveServer() {
        let server = ServerConfig(
            id: editingServer?.id ?? UUID(),
            name: name,
            address: address,
            port: Int(port) ?? 443,
            type: protocolType,
            uuid: uuid,
            alterId: protocolType == .vmess ? Int(alterId) : nil,
            encryption: protocolType == .vmess ? vmessSecurity : vlessEncryption,
            flow: protocolType == .vless && !flow.isEmpty ? flow : nil,
            network: network,
            security: security,
            sni: !sni.isEmpty ? sni : nil,
            fingerprint: security != "none" ? fingerprint : nil,
            alpn: !alpn.isEmpty ? alpn : nil,
            allowInsecure: allowInsecure,
            wsPath: network == "ws" ? wsPath : nil,
            wsHost: network == "ws" && !wsHost.isEmpty ? wsHost : nil,
            grpcServiceName: network == "grpc" && !grpcServiceName.isEmpty ? grpcServiceName : nil,
            grpcMode: network == "grpc" ? grpcMode : nil,
            httpPath: nil,
            httpHost: nil,
            realityPublicKey: security == "reality" ? realityPublicKey : nil,
            realityShortId: security == "reality" ? realityShortId : nil,
            realitySpiderX: security == "reality" && !realitySpiderX.isEmpty ? realitySpiderX : nil
        )
        
        if isEditing {
            appState.updateServer(server)
        } else {
            appState.addServer(server)
        }
        
        dismiss()
    }
}

#Preview {
    AddServerView()
        .environmentObject(AppState.shared)
}
