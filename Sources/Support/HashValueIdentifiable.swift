//
//  HashValueIdentifiable.swift
//
//  Created by Corey Davis on 3/18/25.
//

#if os(iOS)
public protocol HashValueIdentifiable: Hashable, Identifiable {}

public extension HashValueIdentifiable {
    var id: Int { hashValue }
}
#endif
