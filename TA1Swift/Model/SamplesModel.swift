//
//  SamplesModel.swift
//  TA1Swift
//
//  Created by Ivan Manov on 29.03.2021.
//

import Foundation

struct SampleDataSource: Hashable {
    private let outSender = SampleSender(
        senderId: "00", senderFullName: "Unknown", senderMeta: "Unk"
    )
    private let inSender = SampleSender(
        senderId: "01", senderFullName: "Long Sender Nameeeeeeeeeeee", senderMeta: "Patient"
    )
    
    func loadMessages(callback: @escaping (_ messages: [SampleMessage]) -> Void) {
        callback([
            SampleMessage(sender: self.inSender,
                          media: [
                            URL(string: "https://placebear.com/g/200/300")!,
                            URL(string: "https://placebear.com/g/300/300")!,
                            URL(string: "https://placebear.com/g/400/400")!,
                          ],
                          sentTimestamp: "2023-01-25T16:50:00+03:00"),
            SampleMessage(sender: self.inSender,
                          media: [
                            URL(string: "https://placebear.com/g/300/400")!
                          ],
                          sentTimestamp: "2023-01-29T09:00:00+03:00"),
            SampleMessage(sender: self.outSender,
                          media: [
                            URL(string: "https://placebear.com/g/200/400")!
                          ],
                          sentTimestamp: "2023-01-31T10:30:00+03:00"),
            SampleMessage(sender: self.outSender,
                          media: [
                            URL(string: "https://placebear.com/g/400/400")!,
                            URL(string: "https://placebear.com/g/200/200")!,
                            URL(string: "https://placebear.com/g/300/400")!,
                            URL(string: "https://placebear.com/g/300/200")!,
                          ],
                          sentTimestamp: "2023-01-31T12:10:00+03:00")
        ])
    }
}

struct SampleMessage: Hashable {
    let sender: SampleSender?
    let media: [URL]?
    let sentTimestamp: String?
}

struct SampleSender: Hashable {
    let senderId: String
    let senderFullName: String
    let senderMeta: String?
	
	var isMe: Bool { senderId == Session.userId }
}
