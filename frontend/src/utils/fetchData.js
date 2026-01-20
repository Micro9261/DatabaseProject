import { useAuth } from "../Context/AuthContext";

export function createFetchWithAuth({ accessToken, setAccessToken, logout }) {
  const baseURL = "http://localhost:3000/api";

  return async function fetchWithAut(url, options = {}, retry = false) {
    const savedAccessToken = accessToken;

    const response = await fetch(`${baseURL}${url}`, {
      ...options,
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        ...(options.headers || {}),
        ...(savedAccessToken
          ? { Authorization: `Bearer ${savedAccessToken}` }
          : {}),
      },
    });

    console.log(response.status, response.message);
    if (!response.ok && response.status == 403) {
      if (!retry) {
        try {
          const refreshRes = await fetch(`${baseURL}/users/refresh`, {
            method: "POST",
            credentials: "include",
          });

          if (!refreshRes.ok) {
            throw new Error("Refresh failed");
          }

          const data = await refreshRes.json();
          const newAccessToken = data.accessToken;
          setAccessToken(newAccessToken);
          return fetchWithAut(url, options, true);
        } catch (err) {
          console.log(err);
          logout();
        }
      }
      logout();
    }

    return response;
  };
}

export function useFetchWithAuth() {
  const { accessToken, setAccessToken, logout } = useAuth();

  const fetchWithAuth = createFetchWithAuth({
    accessToken,
    setAccessToken,
    logout,
  });
  return fetchWithAuth;
}
