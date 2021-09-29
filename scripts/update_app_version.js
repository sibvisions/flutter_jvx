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

const setYamlValue = (fn, callback) =>
    fs
      .readFile(fn, 'utf-8')
      .then((body) => YAML.parse(body))
      .then((yaml) => {
        return callback(yaml);
      })
      .then((yaml) => YAML.stringify(yaml))
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

if (process.argv[2] != null) {
  if (process.argv[2] == "build") {
    setValue(path, (json) => {
      const splittedVersion = json.version.split("+");

      const updatedNumber = (parseInt(splittedVersion[1]) + 1).toString();

      splittedVersion[1] = updatedNumber;

      json.version = splittedVersion.join("+");

      return json;
    });

    setYamlValue(yamlPath, (yaml) => {
      const splittedVersion = yaml.version.split("+");

      const updatedNumber = (parseInt(splittedVersion[1]) + 1).toString();

      splittedVersion[1] = updatedNumber;

      yaml.version = splittedVersion.join("+");

      return yaml;
    });


  } else if (process.argv[2] == "commit") {
    exec("git rev-parse --short HEAD", (error, stdout, stderr) => {
      if (error) {
        console.log(`error: ${error.message}`);
      }

      if (stderr) {
        console.log(`stderr: ${stderr}`);
      }

      setValue(path, (json) => {
        json.commit = stdout.trim();
        return json;
      });
    });
  } else if (process.argv[2] == "date") {
    setValue(path, (json) => {
      var newDate = Date.now()

      json.date = newDate;

      return json;
    });
  } else if (process.argv[2] == "version") {

    const newVersion = process.argv[3];

    if (newVersion!=null) {
      setValue(path, (json) => {
        const splittedVersion = json.version.split("+");

        splittedVersion[0] = newVersion;

        json.version = splittedVersion.join("+");

        return json;
      });

      setYamlValue(yamlPath, (yaml) => {
        const splittedVersion = yaml.version.split("+");

        splittedVersion[0] = newVersion;

        yaml.version = splittedVersion.join("+");

        return yaml;
      });
    } else {
      console.log('Missing version!');
    }  
  } 
} else {
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
    console.log('commit1' + commit);

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
}
