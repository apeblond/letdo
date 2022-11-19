import { ConnectButton } from "@rainbow-me/rainbowkit";
import Tabs from "../components/Tabs";
import Encrypt from "../components/Encrypt";
import Decrypt from "../components/Decrypt";
import { useState } from "react";

const Home = () => {
  const [addressStore, setAddressStore] = useState("");
  return (
    <div className="py-6 justify-center text-center">
      <div className="flex justify-center">
        <ConnectButton />
      </div>
      <h1 className="text-4xl font-bold mt-6">Letdo</h1>
      <div className="mb-4 m-5">
        <input
          className="shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline"
          id="username"
          type="text"
          placeholder="Store Address"
          onChange={(event) => {
            setAddressStore(event.target.value);
          }}
        />
      </div>
      <Tabs
        firstElement={{
          title: "Encrypt Info",
          component: <Encrypt addressStore={addressStore} />,
        }}
        secondElement={{ title: "Decrypt Info", component: <Decrypt /> }}
        thirdElement={{ title: "Shop", component: <p>Coming Soon</p> }}
      />
    </div>
  );
};

export default Home;
