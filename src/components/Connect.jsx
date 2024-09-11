import Web3 from "web3";
import contractABI from "../contracts/main.json";
import profileContractABI from "../contracts/user.json";

const contractAddress = "0xD03ed2100F59eD19819093eDf1bf8618cC71Dc63";
const profileContractAddress = "0xDb17eDFBC8e9b5AAaea0fF0885E3B0f99771727E";

const Connect = ({
  web3,
  account,
  shortAddress,
  setContract,
  setAccount,
  setProfileContract,
  setWeb3,
}) => {
  async function switchToSepolia() {
    try {
      // Request user to switch to Sepolia
      await window.ethereum.request({
        method: "wallet_switchEthereumChain",
        params: [{ chainId: "0xaa36a7" }],
      });
    } catch (switchError) {
      if (switchError.code === 4902) {
        try {
          await window.ethereum.request({
            method: "wallet_addEthereumChain",
            params: [
              {
                chainId: "0xaa36a7",
                chainName: "Sepolia",
                nativeCurrency: {
                  name: "ETH",
                  symbol: "ETH",
                  decimals: 18,
                },
                rpcUrls: ["https://rpc.sepolia.org"],
              },
            ],
          });
        } catch (addError) {
          console.error("Failed to add Sepolia network to MetaMask", addError);
        }
      } else {
        console.error("Failed to switch to Sepolia network", switchError);
      }
    }
  }

  async function connectWallet() {
    if (window.ethereum) {
      try {
        await window.ethereum.enable();
        const networkId = await window.ethereum.request({
          method: "net_version",
        });

        if (networkId !== "100") {
          await switchToSepolia();
        }

        const tempWeb3 = new Web3(window.ethereum);
        setWeb3(tempWeb3);
        const contractInstance = new tempWeb3.eth.Contract(
          contractABI,
          contractAddress
        );

        const profileContractInstance = new tempWeb3.eth.Contract(
          profileContractABI,
          profileContractAddress
        );
        setProfileContract(profileContractInstance);
        console.log("HIIIIIII");
        const accounts = await tempWeb3.eth.getAccounts();
        console.log("aCCOUNTS", accounts);
        if (accounts.length > 0) {
          setContract(contractInstance);
          setAccount(accounts[0]);
        }
        console.log("NAHHHHHH");
      } catch (error) {
        console.error(error);
      }
    } else {
      console.error("No web3 provider detected");
    }
  }

  return (
    <>
      <div className="connect">
        {!account ? (
          <button id="connectWalletBtn" onClick={connectWallet}>
            Connect Wallet
          </button>
        ) : (
          <div id="userAddress">Connected: {shortAddress(account)}</div>
        )}
      </div>
      <div id="connectMessage">
        {!account ? "Please connect your wallet to tweet." : ""}
      </div>
    </>
  );
};

export default Connect;
