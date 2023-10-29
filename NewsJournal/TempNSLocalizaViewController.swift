//
//  TempNSLocalizaViewController.swift
//  NewsJournal
//
//  Created by Heedon on 2023/10/11.
//

import Foundation

//Localizable.Strings 활용
//        nicknameTextField.placeholder = NSLocalizedString("nickname_placeholder", comment: "")

//연산 프로퍼티로 활용 (String Literal은 enum으로 연결해놓을 수도 있음)
//nicknameTextField.placeholder = "nickname_placeholder".localized

//String data 대응: %@에 가변 매개변수 값이 들어감
//매개변수 개수 설정은 Localizable.strings와 동일해야 함
//let value = NSLocalizedString("nickname_result", comment: "")
//resultLabel.text = String(format: value, "고래밥")


//Int를 String으로 변환해서 적용
//resultLabel.text = "age_result".localized(number: 55)





extension String {
    
    //연산 프로퍼티로 활용
    var localized: String {
        //comment: 부가적 설명, 보통은 잘 쓸 일이 없음
        return NSLocalizedString(self, comment: "")
    }
    
    //Int값을 String으로 변환, 대응하기
    func localized(number: Int) -> String {
        return String(format: self.localized, number)
    }
}
