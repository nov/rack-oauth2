class Time
  class << self
    def now_with_fixed_time
      if @fixed_time
        @fixed_time.dup
      else
        now_without_fixed_time
      end
    end

    alias_method :now_without_fixed_time, :now
    alias_method :now, :now_with_fixed_time

    def fix(time = Time.now)
      @fixed_time = time
      yield
    ensure
      @fixed_time = nil
    end
  end
end
