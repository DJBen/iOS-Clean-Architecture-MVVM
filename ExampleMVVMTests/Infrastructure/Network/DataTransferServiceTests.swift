//
//  DataTransferServiceTests.swift
//  ExampleMVVMTests
//
//  Created by Oleh Kudinov on 16.08.19.
//

import XCTest

private struct MockModel: Decodable {
    let name: String
}

class DataTransferServiceTests: XCTestCase {
    
    private enum DataTransferErrorMock: Error {
        case someError
    }
    
    func test_whenReceivedValidJsonInResponse_shouldDecodeResponseToDecodableObject() {
        //given
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should decode mock object")

        let response = HTTPURLResponse(url: URL(string: "test_url")!,
                                       statusCode: 200,
                                       httpVersion: "1.1",
                                       headerFields: [:])
        let responseData = #"{"name": "Hello"}"#.data(using: .utf8)
        let networkService = DefaultNetworkService(config: config, sessionManager: NetworkSessionManagerMock(response: response,
                                                                                                             data: responseData,
                                                                                                             error: nil))
        
        let sut = DefaultDataTransferService(with: networkService)
        //when
        _ = sut.request(with: Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get)).sink(receiveCompletion: { (_) in
        }) { (result) in
            XCTAssertEqual(result.name, "Hello")
            expectation.fulfill()
        }
        //then
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_whenInvalidResponse_shouldNotDecodeObject() {
        //given
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should not decode mock object")

        let response = HTTPURLResponse(url: URL(string: "test_url")!,
                                       statusCode: 200,
                                       httpVersion: "1.1",
                                       headerFields: [:])
        let responseData = #"{"age": 20}"#.data(using: .utf8)
        let networkService = DefaultNetworkService(config: config, sessionManager: NetworkSessionManagerMock(response: response,
                                                                                                             data: responseData,
                                                                                                             error: nil))
        
        let sut = DefaultDataTransferService(with: networkService)
        //when
        _ = sut.request(with: Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get)).sink(receiveCompletion: { (completion) in
            switch completion {
                case .finished:
                    XCTFail("Should not happen")
                case .failure:
                    expectation.fulfill()
            }
        }) { (_) in }
        //then
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_whenBadRequestReceived_shouldRethrowNetworkError() {
        //given
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should throw network error")
        
        let responseData = #"{"invalidStructure": "Nothing"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(url: URL(string: "test_url")!,
                                       statusCode: 500,
                                       httpVersion: "1.1",
                                       headerFields: nil)
        let networkService = DefaultNetworkService(config: config, sessionManager: NetworkSessionManagerMock(response: response,
                                                                                                             data: responseData,
                                                                                                             error: nil))
        
        let sut = DefaultDataTransferService(with: networkService)
        //when
        _ = sut.request(with: Endpoint<MockModel>(path: "http://mock.endpoint.com", method: .get)).sink(receiveCompletion: { (completion) in
            switch completion {
                case .finished:
                    XCTFail("Should not happen")
                case .failure(let error):
                    if case DataTransferError.networkFailure(.generic(NetworkError.error(statusCode: 500, _))) = error {
                        expectation.fulfill()
                }
            }
        }) { (_) in }
        //then
        wait(for: [expectation], timeout: 0.1)
    }
}
