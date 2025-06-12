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
func parseBrokenJSONString(jsonString: String, expectedResult: String) throws {
    let result = try #require(OptimisticJSONParser().parse(jsonString))
    #expect(String(describing: result) == expectedResult, "Expected \(expectedResult), got \(result)")
}

@Test
func castParsedJSONtoDictionary() throws {
    let result = try #require(OptimisticJSONParser().parse("{\"coordinates\":[{\"x\":1.0"))

    let dictionary = try #require(result as? [String: Any])
    #expect(dictionary.keys.count == 1, "Expected 1 key, got \(dictionary.keys.count)")
    #expect(dictionary.keys.first == "coordinates", "Expected key 'coordinates', got \(String(describing: dictionary.keys.first))")

    let value = try #require(dictionary["coordinates"] as? [[String: Any]])
    #expect(value.count == 1, "Expected 1 item in coordinates, got \(value.count)")
    #expect(value[0].keys.count == 1, "Expected 1 key in coordinates item, got \(value[0].keys.count)")
    #expect(value[0].keys.first == "x", "Expected key 'x', got \(String(describing: value[0].keys.first))")
    #expect(value[0]["x"] as? Double == 1.0, "Expected x to be 1.0, got \(String(describing: value[0]["x"]))")
}