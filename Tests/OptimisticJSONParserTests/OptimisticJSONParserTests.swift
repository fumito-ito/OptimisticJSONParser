import Testing
@testable import OptimisticJSONParser

let brokenJSONString = [
    "[\"oops\", \"this\", \"is\", \"missing the end bracket",
    "{ \"maybe_a_float\": 12.}",
    "[1, 2, {\"a\": \"apple\"}",
    "[1, 2, {\"a\": \"apple",
    "{\"coordinates\":[{\"x\":1.0"
]

let parsedResults = [
    "[\"oops\", \"this\", \"is\", \"missing the end bracket\"]",
    "[\"maybe_a_float\": 12.0]",
    "[1, 2, [\"a\": \"apple\"]]",
    "[1, 2, [\"a\": \"apple\"]]",
    "[\"coordinates\": [[\"x\": 1.0]]]"
]

@Test(arguments: zip(brokenJSONString, parsedResults))
func optimizeBrokenJSON(jsonString: String, expectedResult: String) async throws {
    let result = try #require(OptimisticJSONParser().parse(jsonString))
    #expect(String(describing: result) == expectedResult, "Expected \(expectedResult), got \(result)")
}
