
class RawScript {
  String contentAsYaml;

  RawScript(this.contentAsYaml);
}


abstract class RawScriptRepository {

  RawScript findById(String id);
}