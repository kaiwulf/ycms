defmodule Tags do
    def replace_tags(input_file, output_file, replacements) do
        content = File.read!(input_file)
        replace_content = replace_all_tags(content, replacements)
        File.write!(output_file, replaced_content)
    end

    defp replace_all_tags(content, replacements) do
        Enum.reduce(replacements, content, fn {key, val}, acc -> tag = "%{#key}}%"
        String.replace(acc, tag, to_string(value))
    end)
end

# Example usage.
# To-Do: Replace in/out put files with filenames taken from argv and import replacements from user defined file, such as a .ini file, which is converted to an elixir map.

input_file = "input.txt"
output_file = "output.txt"
replacements = %{
    "name" => "John Doe",
    "age" => 30,
    "city" => "New York"
}

Tags.replace_tags(input_file, output_file, replacements)