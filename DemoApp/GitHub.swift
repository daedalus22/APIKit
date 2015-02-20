import Foundation
import APIKit
import LlamaKit

class GitHub: API {
    override class func baseURL() -> NSURL {
        return NSURL(string: "https://api.github.com")!
    }

    override class func requestBodyEncoding() -> RequestBodyEncoding {
        return .JSON(nil)
    }

    override class func responseBodyEncoding() -> ResponseBodyEncoding {
        return .JSON(nil)
    }

    class Request {
        // https://developer.github.com/v3/search/#search-repositories
        class SearchRepositories: APIKit.Request {
            enum Sort: String {
                case Stars = "stars"
                case Forks = "forks"
                case Updated = "updated"
            }

            enum Order: String {
                case Ascending = "asc"
                case Descending = "desc"
            }

            typealias Response = [Repository]

            let query: String
            let sort: Sort
            let order: Order

            var URLRequest: NSURLRequest {
                return GitHub.URLRequest(.GET, "/search/repositories", ["q": query, "sort": sort.rawValue, "order": order.rawValue])
            }

            init(query: String, sort: Sort = .Stars, order: Order = .Ascending) {
                self.query = query
                self.sort = sort
                self.order = order
            }

            func responseFromObject(object: AnyObject) -> Response? {
                var repositories = [Repository]()

                if let dictionaries = object["items"] as? [NSDictionary] {
                    for dictionary in dictionaries {
                        if let repository = Repository(dictionary: dictionary) {
                            repositories.append(repository)
                        }
                    }
                }

                return repositories
            }
        }

        // https://developer.github.com/v3/search/#search-users
        class SearchUsers: APIKit.Request {
            enum Sort: String {
                case Followers = "followers"
                case Repositories = "repositories"
                case Joined = "joined"
            }

            enum Order: String {
                case Ascending = "asc"
                case Descending = "desc"
            }

            typealias Response = [User]

            let query: String
            let sort: Sort
            let order: Order

            var URLRequest: NSURLRequest {
                return GitHub.URLRequest(.GET, "/search/users", ["q": query, "sort": sort.rawValue, "order": order.rawValue])
            }

            init(query: String, sort: Sort = .Followers, order: Order = .Ascending) {
                self.query = query
                self.sort = sort
                self.order = order
            }

            func responseFromObject(object: AnyObject) -> Response? {
                var users = [User]()

                if let dictionaries = object["items"] as? [NSDictionary] {
                    for dictionary in dictionaries {
                        if let user = User(dictionary: dictionary) {
                            users.append(user)
                        }
                    }
                }
                
                return users
            }
        }
    }

    // NOTE: I don't know why this class is needed to avoid segmentation fault in Swift 1.1
    private class SegmentationFaultWorkaround: NSMutableURLRequest {
        convenience init(method: String) {
            self.init()
            HTTPBody = NSJSONSerialization.dataWithJSONObject(NSDictionary(), options: nil, error: nil)
        }
    }
}
