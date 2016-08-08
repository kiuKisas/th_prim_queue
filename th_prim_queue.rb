require 'thread'

class th_prim_queue

  def initialize(elems=nil, &block)
    @mtx = Mutex.new
    @cvar = ConditionVariable.new
    @nbr_wait = 0

    @elems = [nil]
    @cmp = block || lambda { |a,b| a >= b }
    elems.each do |elem| push(elem) end if elems != nil
  end

  def push(elem)
    Thread.handle_interrupt(StandardError => :on_blocking) do
      @mtx.synchronize do
        @elems << elem
        heapify_up(@elems.size - 1)
        @cvar.signal
      end
    end
    self
  end

  def clear
    @mtx.synchronize do
      @elems.clear
      @elems[nil]
    end
  end


  def pop(no_block=false)
    Thread.handle_interrupt(StandardError => :on_blocking) do
      @mtx.synchronize do
        while true
          if @elems.size == 1
            if no_block
              raise ThreadError, "queue empty"
            else
              begin
                @nbr_wait += 1
                @cvar.wait @mtx
              ensure
                @nbr_wait -= 1
              end
            end
          else
            switch(1, @elems.size - 1)
            ret = @elems.pop
            heapify_down(1)
            return ret
          end
        end
      end
    end
  end

  def empty?
    @elems.size == 1
  end

  def size
    @elems.size - 1
  end

  def num_waiting
    @mtx.synchronize do
      return @nbr_wait
    end
  end

  alias :<< :push
  alias :enq :push
  alias :deq :pop
  alias :shift :pop
  alias :length :size

  protected

    def switch(first, second)
      @elems[first], @elems[second] = @elems[second], @elems[first]
    end

    def heapify_up(index)
      return if index <= 1
      pindex = index / 2
      return if @cmp.call(@elems[pindex], @elems[index])
      switch(index, pindex)
      heapify_up(pindex)
    end

    def heapify_down(index)
      cindex = index * 2
      return if cindex > @elems.size - 1
      cindex += 1 if cindex < (@elems.size - 1) && @cmp.call(@elems[cindex + 1], @elems[cindex])
      return if @cmp.call(@elems[index], @elems[cindex])
      switch(index, cindex)
      heapify_down(cindex)
    end

end
