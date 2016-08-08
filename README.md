# Thread safe Priority Queue

A thread safe priority queue implementation in pure Ruby which tends to mimic the original ruby queue in use.

## Complexity

It use a binary search to order the queue, so the complexity increases about `O(log(n))` at every push.

## Usage

```
initialize(elems=nil, &block)
```

initialize takes two optionals parameters:
- elems that you can store in queue, it must be an array
- a lambda which will be use to sort the queue. By default, it sort by descendant order like this:
`lambda { |a,b| a >= b }`

For the rest, it's rather the same as [ruby queue](http://ruby-doc.org/core-2.2.0/Queue.html).

## To Do

- tests

## License

This code is under Beer-Ware Licence, you can see `LICENCE.md` for more information.
