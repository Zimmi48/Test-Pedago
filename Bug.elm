type X a = X Int

v = if True then X 0 else { x = 0 }

f : X -> ()
f { x } = ()
