-- Automatically derives a BUILD_NUM const from the number of git
-- commits to the current working copy. Obviously only works if you
-- are using git and have a complete working copy (not a shallow clone)
--
-- Usage
-- @pragma(after_build_schema) git_buildnum
--
-- Depends on the `git` binary being available.
do
  local build_num, err = rez.plugin.run("git", {"rev-list", "--count", "HEAD"})
  if build_num then
    build_num = math.tointeger(tonumber(build_num))
    compilation = rez.compilation.add_numeric_const(compilation, "BUILD_NUM", build_num)
  else
    print("Error in get_build_number plugin. Exit code: " .. err)
  end

  return compilation
end