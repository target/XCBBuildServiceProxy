# MessagePack

This [MessagePack](https://msgpack.org) implementation is based on the wonderful work of [https://github.com/a2/MessagePack.swift](https://github.com/a2/MessagePack.swift).

We are using a fork because XCBBuildService requires fixed size integers (i.e. `.int64` versus `.int`). After forking we also modified it to tightly integrate with the way it was being used.
