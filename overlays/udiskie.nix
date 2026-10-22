final: prev: {
  udiskie = prev.udiskie.overridePythonAttrs (old: {
    doCheck = false;
  });
}
