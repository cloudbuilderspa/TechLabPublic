const dotenv = require("dotenv");

module.exports = async ({ options, resolveConfigurationProperty }) => {
  // Load env vars into Serverless environment
  // You can do more complicated env var resolution with dotenv here
  // trigger !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  const env = dotenv.config({ path: ".env" }).parsed;
  return env;
};
