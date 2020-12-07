//
//  ViewController.swift
//  colorwheel
//
//  Created by Don Browning on 11/26/20.
//

// https://gist.github.com/cmoulton/7ddc3cfabda1facb040a533f637e74b8
// https://medium.com/dev-genius/how-to-make-http-requests-with-urlsession-in-swift-4dced0287d40
import Cocoa
import SwiftyJSON

class ViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var textLightNumber: NSTextField!
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var stateLabel: NSTextField!
    @IBOutlet weak var hueLabel: NSTextField!
    
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    
    var lights: [String?: LightsInfo] = [:]
    var selectedLight: String = ""
    var hueUsername = "PNNmIH9ajNZy2p1nhVnzsEtwYgsEmY2zvBjrrhlq"
    
    var _colorWheel: ColorWheel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selItem = tableView.selectedRow
        let lightNumbers = [String?] (self.lights.keys)
        
        
        selectedLight = lightNumbers[selItem]!
        print("Setting: " + selectedLight)
        
    }

    // MARK: - Button Click events

    @IBAction func lightInfoClicked(_ sender: NSButton) {
        
        // get the id from  the selected tablecell
        
        
        // going after light 17 first
        if self.selectedLight == "" { return }
        
        print("going after " + self.selectedLight)
        
        let connection = HueConnection(username: self.hueUsername)
        let newUrlComps = connection.GetLightURL(lightNumber: self.selectedLight)
    
        getLightDetail(urlComps: newUrlComps!, completion: {lightDetail, error in
            DispatchQueue.main.async {
                let nameLabel = "Name: " + (lightDetail?.name != nil ? lightDetail!.name : "none")
                let stateLabel = "State: " + (lightDetail?.state != nil ? String(lightDetail!.state.on): "unk")
                let hueLabel = "Hue: " + (lightDetail?.state.hue! != nil ? String(lightDetail!.state.hue!) : "unk")
                
                self.nameLabel.stringValue = nameLabel
                self.stateLabel.stringValue = stateLabel
                self.hueLabel.stringValue = hueLabel
            }
            
        })
            
        
    }
    
    
    @IBAction func toggleLightStateClicked(_ sender: NSButton) {
       
        
        do {
            let hc = HueConnection(username: hueUsername)
            let cw = ColorWheel()
            let blue = cw.GetColorState(primary: true, color: .blue)
            
            
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(blue)
            let json = String(data: jsonData, encoding: .utf8)
            
            print(json)
            
            print("starting PUT")
            
            let urlComps = hc.GetLightState(lightNumber: self.selectedLight)
            
            var request = URLRequest(url: urlComps!.url!)
            request.httpMethod = "PUT"
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "no data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String:Any]{
                    print(responseJSON)
                }
            }.resume()
            
        } catch {
            print("damn, didn't work")
        }
    }
    
    
    @IBAction func buttonClicked(_ sender: NSButton) {
        
        let connection = HueConnection(username: hueUsername)
        let newUrlComps = connection.GetLightsURL()
        print(newUrlComps?.url)
        
        getLightsInfo(urlComps: newUrlComps!, completion:{lights, error in
            
            guard let lights = lights else {return}
            
            self.lights = lights
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
            
        })
    }
    
    
    @IBAction func startColorWheel(_ sender: NSButton) {
        _colorWheel = ColorWheel()
        
        _colorWheel?.SetInitialWheelPosition()
        
        _colorWheel?.Start(interval: 4.0)
        
        self.startButton.isEnabled = false
        self.stopButton.isEnabled = true
        
        
    }
    
    @IBAction func stopColorWheel(_ sender: NSButton) {
        _colorWheel?.Stop()
        self.startButton.isEnabled = true
        self.stopButton.isEnabled = false
    }
    
    
    // MARK: - functions
    
    func getLightsInfo(urlComps: URLComponents, completion:@escaping ([String:LightsInfo]?, Error?) -> Void) {
        let session = URLSession.shared
        
        guard let url = urlComps.url else { return }
        
        session.dataTask(with: url) {data, response, error in
            print("Fetching light information....")
            
            if let error = error {
                print(error)
                completion(nil, error)
            }else
            if let data = data{
                let lights: [String:LightsInfo] = try! JSONDecoder().decode(Welcome.self, from: data)
    
                completion(lights, nil)
            }
        }.resume()
        
    }
    
    func getLightDetail(urlComps: URLComponents, completion:@escaping (LightDetail?, Error?) -> Void) {
        let session = URLSession.shared
        
        guard let url = urlComps.url else {
            return
        }
        
        session.dataTask(with: url){data, response, error in
            print("Fetching light detail.....")
            
            if let error = error{
                print(error)
                completion(nil, error)
            } else
            if let data = data {
                let lightDetail: LightDetail = try! JSONDecoder().decode(LightDetail.self, from: data)
                
                completion(lightDetail, nil)
            }
            
        }.resume()
    }
}

extension ViewController: NSTableViewDataSource{
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.lights.count
    }
}

extension ViewController: NSTableViewDelegate{
    func tableView(_ tableView:NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        //let currentPurchase = viewModel.purchases[row]
        
        let keys = [String?] (self.lights.keys)
        let vals = [LightsInfo] (self.lights.values)
        
                
        // this would be the collection
        
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "lightID") {
         
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "lightIDCell")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                //cellView.textField?.integerValue = currentPurchase.id ?? 0
                cellView.textField?.stringValue = keys[row]!
                return cellView
         
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "lightName") {
         
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "lightDetailCell")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                //cellView.textField?.stringValue = currentPurchase.userInfo?.username ?? ""
                cellView.textField?.stringValue = vals[row].name
         
         
                return cellView
         
         
            } else {
         
            }
         
            return nil
    }
    
    
}


extension NSTableView{
    func selectRow(at index: Int) {
            selectRowIndexes(.init(integer: index), byExtendingSelection: false)
            if let action = action {
                perform(action)
            }
        }
}
