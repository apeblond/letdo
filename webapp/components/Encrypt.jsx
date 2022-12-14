import { useRef, useState, useEffect } from "react";
import { useContractRead } from "wagmi";
import { encryptText } from "../lib/encrypt-decrypt";
import letdoStoreABI from "../abi/LetdoStore.json";

const Encrypt = ({ addressStore }) => {
  const infoRef = useRef(null);
  const [publicKey, setPublicKey] = useState("");
  const [encryptedInfo, setEncryptedInfo] = useState("");
  const publicKeyStoreContractRead = useContractRead({
    address: addressStore,
    abi: letdoStoreABI,
    functionName: "storePublicKey",
  });

  useEffect(() => {
    if (addressStore) {
      publicKeyStoreContractRead.refetch();
    }

    if (publicKey && infoRef.current.value) {
      encryptInfo(infoRef.current.value, publicKey);
    }
  }, [addressStore, infoRef.current?.value, publicKey]);

  const onEncrypt = async () => {
    setPublicKey(publicKeyStoreContractRead.data);
    if (publicKey && infoRef.current.value) {
      encryptInfo(infoRef.current.value, publicKey);
    }
  };

  const encryptInfo = async (text, key) => {
    console.log("Encrypting!");
    const encrypted = await encryptText(text, key);
    setEncryptedInfo(encrypted);
  };

  return (
    <div className="w-full max-w-xs items-center">
      <div>
        <label
          className="block text-gray-700 text-sm font-bold mb-2"
          htmlFor="info"
        >
          Delivery Info To Encrypt
        </label>
        <textarea
          ref={infoRef}
          id="info"
          rows="4"
          className="block p-2.5 w-full text-sm text-gray-900 bg-gray-50 rounded-lg border focus:ring-blue-500"
          placeholder="Enter the delivery info to be encrypted"
        />
      </div>

      <div className="flex items-center justify-between">
        <button
          className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded focus:outline-none focus:shadow-outline"
          type="button"
          onClick={onEncrypt}
        >
          Encrypt
        </button>
      </div>
      {publicKey ? (
        <div className="flex items-center justify-between">
          <p>Store Public Key: {publicKey}</p>
        </div>
      ) : (
        ""
      )}

      {encryptedInfo ? (
        <div className="flex items-center justify-between">
          <div className="mb-4">
            <label
              className="block text-gray-700 text-sm font-bold mb-2"
              htmlFor="info"
            >
              Encrypted Info
            </label>
            <p className="overflow-x-auto break-all">{encryptedInfo}</p>
          </div>
        </div>
      ) : (
        ""
      )}
    </div>
  );
};

export default Encrypt;
