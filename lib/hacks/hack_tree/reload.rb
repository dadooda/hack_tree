HackTree.define do
  group :hack_tree do
    desc <<-EOT
      Reload application hacks

      Load every file under `lib/hacks/`.
    EOT
    hack :reload do
      Dir["lib/hacks/**/*.rb"].each do |fn|
        load fn
      end

      # Signal something more positive than nil.
      true
    end
  end
end
