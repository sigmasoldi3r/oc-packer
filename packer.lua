--[[--
  Crater
--]]--
local shell = require('shell');

local args, ops = shell.parse(...);

if (ops.h or ops.help) then
  print([[Usage: packer file1 [filen...] [--output=file.lua] [--target=/dir/name]
If no target dir is provided, the current working directory in the moment of]]..
[[ the installation will be used.
If no output file is provided, installer.lua will be used.]]);
  return 0;
end

if (#args <= 0) then
  print([[Missing input files, use -h or --help for help.]]);
  return -1;
end

print('Packing '..(#args)..' files...');

local files = {};

--[[--
  Packs a file in a table.
  @param {string} path
--]]--
local function pack(path)
  local file = io.open(path, 'r');
  local data = file:read('*all');
  file:close();
  data = data:gsub('%[(=-)%[', '[%1=[');
  data = data:gsub('%](=-)%]', ']%1=]');
  files[path] = data;
end

for _, path in pairs(args) do
  pack(path);
end

local file = io.open(ops.output or 'installer.lua', 'w');
file:write([=[--[[--
  Standalone installer script
  Unpacks a series of files into a target directory.
  Generated with Packer
  by Argochamber Interactive 2017
--]]--
local fs = require('filesystem');

local target = ']=]..(ops.target or '')..[=[';

local files = {
]=]);

for k, v in pairs(files) do
  file:write('[\''..k..'\'] = [[');
  file:write(v);
  file:write(']],\n');
end

file:write([=[};

for k, v in pairs(files) do
  local file = io.open(fs.concat(target, k), 'w');
  file:write(v);
  file:close();
end
]=]);

file:close();
