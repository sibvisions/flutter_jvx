const { exec } = require("child_process");
const fs = require("fs").promises;

const setValue = (fn, callback) =>
  fs
    .readFile(fn)
    .then((body) => JSON.parse(body))
    .then((json) => {
      // manipulate your data here
      return callback(json);
    })
    .then((json) => JSON.stringify(json))
    .then((body) => fs.writeFile(fn, body))
    .catch((error) => console.warn(error));

if (process.argv[2] != null) {
  if (process.argv[2] == "version") {
    setValue("env/app_version.json", (json) => {
      const splittedVersion = json.version.split("+");

      const updatedNumber = (parseInt(splittedVersion[1]) + 1).toString();

      splittedVersion[1] = updatedNumber;

      json.version = splittedVersion.join("+");

      return json;
    });
  } else if (process.argv[2] == "commit") {
    exec("git rev-parse --short HEAD", (error, stdout, stderr) => {
      if (error) {
        console.log(`error: ${error.message}`);
      }

      if (stderr) {
        console.log(`stderr: ${stderr}`);
      }

      setValue("env/app_version.json", (json) => {
        json.commit = stdout.trim();
        return json;
      });
    });
  } else if (process.argv[2] == "build_date") {
    setValue("env/app_version.json", (json) => {
      var newDate = new Date().toISOString().
          replace(/T/, ' ').
          replace(/\..+/, '');
      json.build_date = newDate.split(' ')[0];;

      return json;
    });
  }
}
