class Cache

  class << self

    def set_default(key, data)
      return if read(key)
      write(key, data)
    end

    def write(key, data)
      dump = BW::JSON.generate(data).to_s
      NSUserDefaults.standardUserDefaults[storage_key(key)] = dump
      NSUserDefaults.standardUserDefaults[storage_key(key+'_length')] = dump.length
      NSUserDefaults.standardUserDefaults.synchronize
    end

    def read(key)
      res = NSUserDefaults.standardUserDefaults[storage_key(key)]
      length = NSUserDefaults.standardUserDefaults[storage_key(key+'_length')]
      if length
        x = res[0..length] #wtf, length isnt available, do workaround over saving length also in cache
        BW::JSON.parse x # rescue nil
      else
        nil
      end
    end

    private

    def storage_key_prefix
      "#{cache_namespace}_"
    end

    def storage_key key
      "#{storage_key_prefix}#{key}"
    end

    def cache_namespace
      'yawa'
    end

  end

end