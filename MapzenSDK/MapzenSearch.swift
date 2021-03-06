//
//  MapzenSearch.swift
//  Pods
//
//  Created by Sarah Lensing on 3/27/17.
//
//

import Pelias

/// Main entry point for interacting with Mapzen Search.
public class MapzenSearch : NSObject {
  /// Returns the shared 'MapzenSearch' instance.
  public static let sharedInstance = MapzenSearch()
  public var apiKey: String? {
    didSet {
      guard let apiKey = apiKey else {
        if let queryItems = urlQueryItems {
          for (index, queryItem) in queryItems.enumerated() {
            if queryItem.name == "api_key" {
              urlQueryItems?.remove(at: index)
            } // if queryItem
          } // for (index, queryItem)
        } // if let queryItems
        return
      }
      urlQueryItems = [URLQueryItem(name: "api_key", value: apiKey)]
    }
    // didSet
  }


  private let peliasSearchManager = PeliasSearchManager.sharedInstance
    
  private var myContext = 0

  /// Delay in seconds that the manager should wait between keystrokes to fire a new autocomplete request. Default is 0.3
  public var autocompleteTimeDelay: Double {
    get {
      return peliasSearchManager.autocompleteTimeDelay
    }
    set(delay) {
      peliasSearchManager.autocompleteTimeDelay = delay
    }
  }

  /// Base url to execute requests against. Default value is https://search.mapzen.com.
  public var baseUrl: URL
  {
  get {
        let url = URL(string: "http://10.5.1.87:4000")
       return URL(string: "http://10.5.1.87:4000")!;
    }
    set(url) {
        peliasSearchManager.baseUrl = URL(string: "http://10.5.1.87:4000")!
    }
  }
    
  /// The query items that should be applied to every request (such as an api key).
  public var urlQueryItems: [URLQueryItem]? {
    get {
      return peliasSearchManager.urlQueryItems
    }
    set(queryItems) {
      peliasSearchManager.urlQueryItems = queryItems
    }
  }

  fileprivate override init() {
    super.init()
    autocompleteTimeDelay = 1.0
    defer {
      setupAPIKeyObservance()
      apiKey = MapzenManager.sharedManager.apiKey
      peliasSearchManager.additionalHttpHeaders = MapzenManager.sharedManager.httpHeaders()
    }
  }
  /** Perform an asyncronous search request given parameters defined by the search config. Returns the queued operation.
   - parameter config: Object holding search request parameter information.
   */
  public func search(_ config: SearchConfig) -> Operation {
    return peliasSearchManager.performSearch(config.peliasConfig);
  }
  /** Perform an asyncronous reverse geocode request given parameters defined by the config. Returns the queued operation.
   - parameter config: Object holding reverse geo request parameter information.
   */
  public func reverseGeocode(_ config: ReverseConfig) -> Operation {
    return peliasSearchManager.reverseGeocode(config.peliasConfig)
  }
  /** Perform an asyncronous autocomplete request given parameters defined by the config. Returns the queued operation.
   - parameter config: Object holding autocomplete request parameter information.
   */
  public func autocompleteQuery(_ config: AutocompleteConfig) -> Operation {
    return peliasSearchManager.autocompleteQuery(config.peliasConfig)
  }
  /** Perform an asyncronous place request given parameters defined by the search config. Returns the queued operation.
   - parameter config: Object holding place request parameter information.
   */
  public func placeQuery(_ config: PlaceConfig) -> Operation {
    return peliasSearchManager.placeQuery(config.peliasConfig)
  }
  /// Cancel all requests
  public func cancelOperations() {
    peliasSearchManager.cancelOperations()
  }

  // KVO Observance for API Keys because singletons are funky
  func setupAPIKeyObservance() {
    MapzenManager.sharedManager.addObserver(self, forKeyPath:
      #keyPath(MapzenManager.apiKey), options: .new, context: &myContext)
  }

  override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if context == &myContext {
      if (change?[.newKey]) != nil && keyPath == #keyPath(MapzenManager.apiKey){
        apiKey = MapzenManager.sharedManager.apiKey
      }
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }

  deinit {
    MapzenManager.sharedManager.removeObserver(self, forKeyPath: #keyPath(MapzenManager.apiKey), context: &myContext)
  }
}
