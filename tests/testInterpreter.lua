require "lunit"

module("test_interpreter", lunit.testcases)

-- var compiled =
-- {"op":"seq","seq":[{"op":"set","var":"group_size","value":{"choices":{"op":"array","values":[1,10]},"unit":{"op":"get","var":"userid"},"op":"uniformChoice"}},{"op":"set","var":"specific_goal","value":{"p":0.8,"unit":{"op":"get","var":"userid"},"op":"bernoulliTrial"}},{"op":"cond","cond":[{"if":{"op":"get","var":"specific_goal"},"then":{"op":"seq","seq":[{"op":"set","var":"ratings_per_user_goal","value":{"choices":{"op":"array","values":[8,16,32,64]},"unit":{"op":"get","var":"userid"},"op":"uniformChoice"}},{"op":"set","var":"ratings_goal","value":{"op":"product","values":[{"op":"get","var":"group_size"},{"op":"get","var":"ratings_per_user_goal"}]}}]}}]}]};
-- var interpreterSalt = 'foo';

function works_as_intended()
  -- var proc = new Interpreter(compiled, interpreterSalt, { 'userid': 123454});
  -- expect(proc.getParams().specific_goal).toEqual(1);
  -- expect(proc.getParams().ratings_goal).toEqual(320);
end

function allows_overrides()
  -- var proc = new Interpreter(compiled, interpreterSalt, { 'userid': 123454});
  -- proc.setOverrides({'specific_goal': 0});
  -- expect(proc.getParams().specific_goal).toEqual(0);
  -- expect(proc.getParams().ratings_goal).toEqual(undefined);
  --
  -- proc = new Interpreter(compiled, interpreterSalt, { 'userid': 123453});
  -- proc.setOverrides({'userid': 123454});
  -- expect(proc.getParams().specific_goal).toEqual(1);
end
