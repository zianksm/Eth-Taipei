const { hashEndpointWithScope } = require("@selfxyz/core");

const main = () => {
    const endpoint = "https://6455-111-235-226-130.ngrok-free.app";
    const scope = "Sanction-Screening";
    const hash = hashEndpointWithScope(endpoint, scope);
    console.log(hash);
};

main();