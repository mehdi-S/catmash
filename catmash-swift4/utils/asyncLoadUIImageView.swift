import UIKit

let imageCache = NSCache<NSString, AnyObject>()

extension customImageView {
    func loadImageFromUrl(withUrl urlString : String, withDefault defaultUIImage : UIImage?) {
        let url = URL(string: urlString)
        self.image = nil
        
        if let defaultImage = defaultUIImage {
            self.image = defaultImage
        }
        
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // if not, download image from url
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    imageCache.setObject(image, forKey: urlString as NSString)
                    self.image = image
                }
            }
            
        }).resume()
    }
}

extension customUIButton {
    func loadButtonImageFromUrl(withUrl urlString : String, withDefault defaultUIImage : UIImage?) {
        let url = URL(string: urlString)
        self.setImage(nil, for: .normal)
        
        if let defaultImage = defaultUIImage {
            self.setImage(defaultImage, for: .normal)
        }
        
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.setImage(cachedImage, for: .normal)
            return
        }
        
        // if not, download image from url
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    imageCache.setObject(image, forKey: urlString as NSString)
                    self.setImage(image, for: .normal)
                }
            }
            
        }).resume()
    }
}
