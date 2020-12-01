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
    
    var lights: [String?: LightsInfo] = [:]
    var selectedLight: String = ""
    let rootURL = "http://192.168.1.16"
    var hueUsername = "PNNmIH9ajNZy2p1nhVnzsEtwYgsEmY2zvBjrrhlq"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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


    @IBAction func lightInfoClicked(_ sender: NSButton) {
        
        // get the id from  the selected tablecell
        
        
        // going after light 17 first
        if self.selectedLight == "" { return }
        
        print("going after " + self.selectedLight)
        
        if let urlComps = URLComponents(string: "http://192.168.1.16/api/PNNmIH9ajNZy2p1nhVnzsEtwYgsEmY2zvBjrrhlq/lights/17"){
            getLightDetail(urlComps: urlComps, completion: {lightDetail, error in
                print(lightDetail?.name)
                print(lightDetail?.state.on)
            })
        }
        
    }
    
    
    @IBAction func toggleLightStateClicked(_ sender: NSButton) {
    }
    
    
    @IBAction func buttonClicked(_ sender: NSButton) {
        
        let connection = HueConnection(username: hueUsername)
        let newUrlComps = connection.GetLightsURL()
        print(newUrlComps?.url)
        
        let res = getLightsInfo(urlComps: newUrlComps!, completion:{lights, error in
            
            guard let lights = lights else {return}
            
            self.lights = lights
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
            
            /*
            for(lightNumber, lightInfo) in lights{
                print(lightNumber + "  " + lightInfo.name)
                
            }
            
            
            
             * swiftyjson parsing example
            if let dataFromString = jsonResult.data(using: .utf8, allowLossyConversion: false){
                let json = try! JSON(data: dataFromString)
                print(json)
            }
            */
        })
    }
    
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
