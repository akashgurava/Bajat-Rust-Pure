func readFfiString(_ function: () -> UnsafePointer<CChar>?) -> String? {
    guard let string = function() else { return nil }
    return String(cString: string)
}
