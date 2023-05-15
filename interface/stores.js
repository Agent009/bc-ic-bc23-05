import { writable } from 'svelte/store'

//----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
//  REGION:   ENVIRONMENT   ----------   ----------   ----------   ----------   ----------   ----------
//----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

export const isDevelopmentEnv = process.env.NODE_ENV === "development";
//TODO : Add mainnet canister ids when deployed on the IC
export const bc2305CanisterId = isDevelopmentEnv ? "rrkah-fqaaa-aaaaa-aaaaq-cai" : "uv34l-oaaaa-aaaap-qa4ua-cai"
export const HOST = isDevelopmentEnv ? "http://localhost:3000/" : "https://ic0.app";

//----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
//  REGION:    NAVIGATION   ----------   ----------   ----------   ----------   ----------   ----------
//----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

export const view = writable({
    home: 1,
    airdrops: 2,
    transfer: 3,
    current: 1,
});

//----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
//  REGION:       AUTH      ----------   ----------   ----------   ----------   ----------   ----------
//----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

export const isAuthenticated = writable(false);
export const accountId = writable(null);
// Returns "@dfinity/principal";
export const principal = writable(null);
export const principalId = writable(null);
// Plug sample return:
// {agent: Nt, principalId: 'bi3lr-cwsga-wc4qg-ypqug-mkn4l-2l436-yxpkm-dozec-ah3nq-qmjqo-lae', accountId: '18235dcaa87a03c8744dce0656324c46c440ad6782c3dc3af5a7dccbdecb9d7e'}
export const authSessionData = writable(null);

//----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
//  REGION:    APP LOGIC    ----------   ----------   ----------   ----------   ----------   ----------
//----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

export const airdrop = writable({airdropID: "", amount: 100});
export const hasReceivedAirdrop = writable(false);
export const ledgerBalance = writable(0);
export const totalSupply = writable(0);
export const totalClaimedSupply = writable(0);
export const remainingSupply = writable(0);
export const bc2305Actor = writable(null);

//----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
//  REGION:      SYSTEM       PARAMS     ----------   ----------   ----------   ----------   ----------
//----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

export const transferFee = writable(null);
export const proposalVoteThreshold = writable(null);
export const proposalSubmissionDeposit = writable(null);