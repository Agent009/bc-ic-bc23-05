import { get } from "svelte/store"
import { Principal } from "@dfinity/principal";
import { isAuthenticated, principal, principalId, bc2305Actor, bc2305CanisterId } from "./stores"
import { idlFactory } from "../src/declarations/bc2305"

//----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
//  REGION:     API CALLS   ----------   ----------   ----------   ----------   ----------   ----------
//----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

/**
 * Get the system parameters.
 */
export async function getSystemParams(bc2305) {
	if (!bc2305) {
		// console.log("getSystemParams --- bc2305Actor not provided.")
		return;
	}

	console.log("ASYNC --- getSystemParams")
	let response;

	try {
		// Fetch the response and handle it in async fashion so we don't get the promise errors in console.
		response = await bc2305
			.get_system_params()
			.then((resp) => {
				console.log("getSystemParams - response: ", resp);
				return resp;
			})
			.catch((error) => {
				console.log("Error getSystemParams (1) - ", error);
				throw new Error(error);
			})
	} catch (error) {
		// Catch-all in case something else goes wrong.
		console.log("Error getSystemParams (2) - ", error);
		throw new Error(error);
	}

	return response;
}

/**
 * Get the staken tokens.
 */
export async function getLedgerBalance(bc2305) {
	console.log("EVENT --- getLedgerBalance")
	let response

	if (!bc2305) {
		return
	}

	try {
		// Fetch the response and handle it in async fashion so we don't get the promise errors in console.
		response = await bc2305.myLedgerBalance()
			.then((resp) => {
				console.log("getLedgerBalance - ", resp)

				if (resp.ok) {
					return resp.ok
				} else {
					throw new Error(resp.err)
				}
			})
			.catch((error) => {
				console.log("Error getLedgerBalance (1) - ", error)
				throw new Error(error)
			})
	} catch (error) {
		// Catch-all in case something else goes wrong.
		console.log("Error getLedgerBalance (2) - ", error)
		throw new Error(error)
	}

	return response
}

/**
 * Get the total token supply.
 */
export async function getTotalSupply(bc2305) {
	// let bc2305 = get(bc2305Actor);

	if (!bc2305) {
		console.log("getTotalSupply --- bc2305Actor not provided.")
		return;
	}

	console.log("ASYNC --- getTotalSupply")
	let response;

	try {
		// Fetch the response and handle it in async fashion so we don't get the promise errors in console.
		response = await bc2305.totalSupply()
			.then((resp) => {
				console.log("getTotalSupply - response: ", resp);
				return resp;
			})
			.catch((error) => {
				console.log("Error getTotalSupply (1) - ", error);
				throw new Error(error);
			})
	} catch (error) {
		// Catch-all in case something else goes wrong.
		console.log("Error getTotalSupply (2) - ", error);
		throw new Error(error);
	}

	return response;
}

/**
 * Get the total token supply.
 */
export async function getTotalClaimedSupply(bc2305) {
	// let bc2305 = get(bc2305Actor);

	if (!bc2305) {
		console.log("getTotalClaimedSupply --- bc2305Actor not provided.")
		return;
	}

	console.log("ASYNC --- getTotalClaimedSupply")
	let response;

	try {
		// Fetch the response and handle it in async fashion so we don't get the promise errors in console.
		response = await bc2305.totalClaimedSupply()
			.then((resp) => {
				console.log("getTotalClaimedSupply - response: ", resp);
				return resp;
			})
			.catch((error) => {
				console.log("Error getTotalClaimedSupply (1) - ", error);
				throw new Error(error);
			})
	} catch (error) {
		// Catch-all in case something else goes wrong.
		console.log("Error getTotalClaimedSupply (2) - ", error);
		throw new Error(error);
	}

	return response;
}

/**
 * Get the total token supply.
 */
export async function getRemainingSupply(bc2305) {
	// let bc2305 = get(bc2305Actor);

	if (!bc2305) {
		console.log("getRemainingSupply --- bc2305Actor not provided.")
		return;
	}

	console.log("ASYNC --- getRemainingSupply")
	let response;

	try {
		// Fetch the response and handle it in async fashion so we don't get the promise errors in console.
		response = await bc2305.remainingSupply()
			.then((resp) => {
				console.log("getRemainingSupply - response: ", resp);
				return resp;
			})
			.catch((error) => {
				console.log("Error getRemainingSupply (1) - ", error);
				throw new Error(error);
			})
	} catch (error) {
		// Catch-all in case something else goes wrong.
		console.log("Error getRemainingSupply (2) - ", error);
		throw new Error(error);
	}

	return response;
}

/**
 * Get the caller's airdrops.
 */
export async function getMyAirdrops(bc2305) {
	if (!bc2305) {
		// console.log("getMyAirdrops --- bc2305Actor not provided.")
		return;
	}

	console.log("ASYNC --- getMyAirdrops")
	let response;

	try {
		// Fetch the response and handle it in async fashion so we don't get the promise errors in console.
		response = await bc2305
			.getMyAirdrops()
			.then((resp) => {
				console.log("getMyAirdrops - response: ", resp);
				return resp;
			})
			.catch((error) => {
				console.log("Error getMyAirdrops (1) - ", error);
				throw new Error(error);
			})
	} catch (error) {
		// Catch-all in case something else goes wrong.
		console.log("Error getMyAirdrops (2) - ", error);
		throw new Error(error);
	}

	return response;
}

//----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
//  REGION:   CONVERSIONS   ----------   ----------   ----------   ----------   ----------   ----------
//----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

/**
 * Encode in UTF8 bytes
 * @param {string} text 
 * @returns 
 */
export function encodeUtf8(text) {
	const arr = [];

	for (const char of text) {
		const codepoint = char.codePointAt(0);

		if (codepoint < 128) {
			arr.push(codepoint);
			continue;
		}

		if (codepoint < 2048) {
			const num1 = 0b11000000 | (codepoint >> 6);
			const num2 = 0b10000000 | (codepoint & 0b111111);

			arr.push(num1, num2);
			continue;
		}

		if (codepoint < 65536) {
			const num1 = 0b11100000 | (codepoint >> 12);
			const num2 = 0b10000000 | ((codepoint >> 6) & 0b111111);
			const num3 = 0b10000000 | (codepoint & 0b111111);

			arr.push(num1, num2, num3);
			continue;
		}

		const num1 = 0b11110000 | (codepoint >> 18);
		const num2 = 0b10000000 | ((codepoint >> 12) & 0b111111);
		const num3 = 0b10000000 | ((codepoint >> 6) & 0b111111);
		const num4 = 0b10000000 | (codepoint & 0b111111);

		arr.push(num1, num2, num3, num4);
	}

	return arr;
}

/**
 * Decode from UTF8 bytes
 * @param {*} bytes 
 * @returns 
 */
export function decodeUtf8(bytes) {
	const arr = [];

	for (let i = 0; i < bytes.length; i++) {
		const byte = bytes[i];

		if (!(byte & 0b10000000)) {
			const char = String.fromCodePoint(byte);
			arr.push(char);
			continue;
		}

		let codepoint, byteLen;

		if (byte >> 5 === 0b110) {
			codepoint = 0b11111 & byte;
			byteLen = 2;
		} else if (byte >> 4 === 0b1110) {
			codepoint = 0b1111 & byte;
			byteLen = 3;
		} else if (byte >> 3 === 0b11110) {
			codepoint = 0b111 & byte;
			byteLen = 4;
		} else {
			// this is invalid UTF-8 or we are in middle of a character
			throw new Error('found invalid UTF-8 byte ' + byte);
		}

		for (let j = 1; j < byteLen; j++) {
			const num = 0b00111111 & bytes[j + i];
			const shift = 6 * (byteLen - j - 1);
			codepoint |= num << shift;
		}

		const char = String.fromCodePoint(codepoint)
		arr.push(char);
		i += byteLen - 1;
	}

	return arr.join('');
}

/**
 * Convert a string to a candid blob representation
 * // In Chrome DevTools:
 * 	const textBlob = new Blob(["Updated page title"], {type: 'text/plain'});
 * 	const byteArray = await [...new Uint8Array(await textBlob.arrayBuffer())]
 * 	byteArray
 * @param {string} text The string to convert
 * @returns {Uint8Array}
 */
export async function textToUnit8Array(text) {
	const textBlob = new Blob([text], { type: 'text/plain' });
	return [...new Uint8Array(await textBlob.arrayBuffer())];
}

//----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
//  REGION:       MISC      ----------   ----------   ----------   ----------   ----------   ----------
//----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

export function getFormattedToken(amount) {
	//if x is a string/non-number, use parseInt/parseFloat to convert to a number.
	let value = Number(amount);

	if (Number.isNaN(value)) {
		return 0 + " MBT";
	}

	return value.toLocaleString('en', { minimumFractionDigits: 0, maximumFractionDigits: 0 }) + " MOC";
}