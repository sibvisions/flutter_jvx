const { exec } = require("child_process");
const fs = require("fs").promises;
const YAML = require('yaml');

const path = "assets/version/app_version.json";
const yamlPath = "pubspec.yaml";

const setValue = (fn, callback) =>
  fs
    .readFile(fn)
    .then((body) => JSON.parse(body))
    .then((json) => {
      return callback(json);
    })
    .then((json) => JSON.stringify(json))
    .then((body) => fs.writeFile(fn, body))
    .catch((error) => console.warn(error));

const getYamlValue = (fn, callback) =>
  fs
    .readFile(fn, 'utf-8')
    .then((body) => YAML.parse(body))
    .then((yaml) => {
      return callback(yaml);
    })
    .catch((error) => console.warn(error));


var version;
var commit;

exec("git rev-parse --short HEAD", (error, stdout, stderr) => {
  if (error) {
    console.log(`error: ${error.message}`);
  }

  if (stderr) {
    console.log(`stderr: ${stderr}`);
  }

  commit = stdout.trim();

  getYamlValue(yamlPath, (yaml) => {
    version = yaml.version;
  });

  setValue(path, (json) => {
    var newDate = Date.now()

    json.version = version;
    json.date = newDate;
    json.commit = commit;

    return json;
  });
})

