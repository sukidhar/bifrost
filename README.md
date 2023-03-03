<p align="center">
  <a href="" rel="noopener">
 <img width=650px src="/images/bifrost-logo.png" alt="Project logo"></a>
</p>

<h2 align="center">Bifrost</h2>

<div align="center">

  [![Status](https://img.shields.io/badge/status-active-success.svg)]() 
  [![GitHub Issues](https://img.shields.io/github/issues/sukidhar/bifrost.svg)](https://github.com/sukidhar/bifrost/issues)
  [![GitHub Pull Requests](https://img.shields.io/github/issues/sukidhar/bifrost.svg)](https://github.com/sukidhar/bifrost/pulls)
  [![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

</div>

---

<p align="center">
  Bifrost is a generic simple reusable networking layer for building swift apps from scratch. It provides the initial kick-start required with the most common functions required to perform HTTP Requests without rewriting and head banging for same old repitive code. It is built with support to Combine and Concurrency async/await.
</p>

## 📝 Table of Contents
- [About](#about)
- [Getting Started](#getting_started)
- [Deployment](#deployment)
- [Usage](#usage)
- [Built Using](#built_using)
- [TODO](../TODO.md)
- [Contributing](../CONTRIBUTING.md)
- [Authors](#authors)
- [Acknowledgments](#acknowledgement)

## 🧐 About <a name = "about"></a>
After building several experimental apps, I came to realise that I am rewriting most of the generic networking over and over across projects. Well. why not use something already popular? For instance Alamofire. Most projects do not really need the huge dependency like Alamofire and can suffice with URLSession. Using `URLSession` and `URLRequest` directly requires you to handle errors manually, depending on how one handles it. To streamline error handling and encapsulate common headers and request mechanism, Bifrost is born. It is light-weight, extensible and supports concurrency.

## 🏁 Getting Started <a name = "getting_started"></a>
### Installing

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

Once you have your Swift package set up, adding Bifrost as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/sukidhar/bifrost.git", .branch(“main”))
]
```

## 🎈 Usage <a name="usage"></a>

Bifrost abstracts away `URL`, `URLRequest` with `Endpoint`. To create an endpoint.

```swift
// by default, each endpoint assumes it's `HTTP` method is `GET`. 
// It expects `urlString` which can be full length resource URL or base URL.

let endpoint = Endpoint(urlString: "https://example.com/user")

// In case, you want to reuse the base url string and deal the endpoints with `path`.

let endpoint = Endpoint(urlString: "https://example.com", path: "request-route")

// In case, you want to change the `HTTP` method to `POST`, provide explicit init attribute.

let endpoint = Endpoint(method: .post, urlString: "https://example.com", path: "request-route")

// Would like to add headers?. Most common headers are included and are available as `Enum`.

let endpoint = Endpoint(method: .post, urlString: "https://example.com", path: "request-route", headers: [[.init(.accept, value: "application/json, text/plain, */*")])
```

Bifrost provides a shared instance to not have instances dangling across the app. 


## ✍️ Authors <a name = "authors"></a>
- [@sukidhar](https://github.com/sukidhar) - Idea & Initial work

See also the list of [contributors](https://github.com/sukidhar/bifrost/contributors) who participated in this project.

## Contributing 

Feel to free open a Pull Request, Issue or Feature requests. For further help or requests, feel free to reach out on my socials. [![Instagram](https://img.shields.io/badge/Instagram-%23E4405F.svg?logo=Instagram&logoColor=white)](https://instagram.com/sukidhar) [![LinkedIn](https://img.shields.io/badge/LinkedIn-%230077B5.svg?logo=linkedin&logoColor=white)](https://linkedin.com/in/sukidhar) 

## License

Bifrost is available under the MIT license. [See LICENSE](https://github.com/sukidhar/bifrost/blob/master/LICENSE) for details.

## 🎉 Acknowledgements <a name = "acknowledgement"></a>
- Hat tip to anyone whose code was used
- Inspiration
- References
