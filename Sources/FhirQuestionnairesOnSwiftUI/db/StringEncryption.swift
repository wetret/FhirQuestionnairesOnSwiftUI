import Foundation
import CryptoKit

internal extension String
{
    func encrypt(using symmetricKey: SymmetricKey) -> String?
    {
        if let data = self.data(using: .utf8)
        {
            let encryptedData = try? AES.GCM.seal(data, using: symmetricKey).combined
            return encryptedData?.base64EncodedString()
        }
        
        return nil
    }
    
    func decrypt(using symmetricKey: SymmetricKey) -> String?
    {
        if let encryptedData = self.data(using: .utf8), let base64EncraptedData = Data(base64Encoded: encryptedData)
        {
            if let sealedBox = try? AES.GCM.SealedBox(combined:  base64EncraptedData), let decryptedData = try? AES.GCM.open(sealedBox, using: symmetricKey)
            {
                return String(data: decryptedData, encoding: .utf8)
            }
        }
        
        return nil
    }
}
