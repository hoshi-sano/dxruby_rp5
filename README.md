# DXRubyRP5

`dxruby_rp5` is a ruby library for 2D graphics and game. `dxruby_rp5`
uses `ruby-processing` and has API same as DXRuby.

* https://github.com/jashkenas/ruby-processing
* http://dxruby.sourceforge.jp/ (in Japanese)

`dxruby-rp5` is inspired by and referring to `dxruby_sdl`.

* https://github.com/takaokouji/dxruby_sdl

## Installation

### Install ruby-processing

see https://github.com/jashkenas/ruby-processing#installation

### Install dxruby_rp5

Add this line to your application's Gemfile:

    gem 'dxruby_rp5'

If your ruby-processing version is lower than 2.4.0 (ex. 2.3.x):

    gem 'dxruby_rp5', '0.0.2'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dxruby_rp5

If your ruby-processing version is lower than 2.4.0 (ex. 2.3.x):

    $ gem install dxruby_rp5 -v 0.0.2

## Usage

```bash
$ dxrp5 --nojruby run my_dxruby_sketch.rb
```

If `my_dxruby_sketch.rb` is like below,

```ruby
require 'dxruby'

x = 0
y = 0
image = Image.load('./images/test.png')

Window.loop do
  x = x + Input.x
  y = y + Input.y

  Window.draw(x, y, image)
end
```

`dxrp5` converts the source code as follows.

```ruby
class Sketch < Processing::App
  def setup
    require 'dxruby'

    x = 0
    y = 0
    image = Image.load('./images/test.png')

    Window.loop do
      x = x + Input.x
      y = y + Input.y

      Window.draw(x, y, image)
    end
  end

  def draw
  end
end
```

And in `Window.loop`, `Sketch#draw` method is defined dynamically.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
