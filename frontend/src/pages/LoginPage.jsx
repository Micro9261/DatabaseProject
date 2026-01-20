import { useFetcher, useNavigate } from "react-router-dom";
import styled from "styled-components";
import { useAuth } from "../Context/AuthContext";
import { useEffect } from "react";

const PageContainer = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  background-color: #f4f6f8;
  font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
`;

const LoginCard = styled.div`
  background: white;
  padding: 40px;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  width: 100%;
  max-width: 400px;
`;

const Title = styled.h2`
  margin-bottom: 24px;
  color: #333;
  text-align: center;
`;

const StyledInput = styled.input`
  width: 100%;
  padding: 12px;
  margin-bottom: 16px;
  border: 1px solid #ddd;
  border-radius: 4px;
  box-sizing: border-box;
  font-size: 16px;

  &:focus {
    border-color: #007bff;
    outline: none;
  }
`;

const ButtonGroup = styled.div`
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
`;

const Button = styled.button`
  flex: 1;
  padding: 12px;
  border: none;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
  transition: background 0.2s;

  &:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
`;

const SubmitButton = styled(Button)`
  background-color: #007bff;
  color: white;

  &:hover:not(:disabled) {
    background-color: #0056b3;
  }
`;

const CancelButton = styled(Button)`
  background-color: #e2e6ea;
  color: #333;

  &:hover:not(:disabled) {
    background-color: #dbe2e8;
  }
`;

const Divider = styled.hr`
  border: 0;
  border-top: 1px solid #eee;
  margin: 20px 0;
`;

const CreateAccountButton = styled(Button)`
  width: 100%;
  background-color: #28a745;
  color: white;

  &:hover {
    background-color: #218838;
  }
`;

const ErrorMessage = styled.div`
  color: #dc3545;
  margin-bottom: 16px;
  text-align: center;
  font-size: 14px;
`;

export async function loginAction({ request }) {
  const formData = await request.formData();
  const rawLogin = formData.get("loginEmail");
  const password = formData.get("password");

  const isEmail = rawLogin.includes("@");

  const payload = {
    password,
    ...(isEmail ? { email: rawLogin } : { login: rawLogin }),
  };

  try {
    const response = await fetch("http://localhost:3000/api/users/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    const data = await response.json();

    if (!response.ok) {
      return { error: "Niepoprawne dane" };
    }

    // return redirect("/");
    return {
      success: true,
      token: data.accessToken,
      role: data.role,
      login: data.login,
    };
  } catch (err) {
    console.log(err);
    return { error: "Błąd serwera!" };
  }
}

export function LoginPage() {
  const fetcher = useFetcher();
  const navigate = useNavigate();
  const { setAccessToken, setUserData } = useAuth();

  const isSubmitting = fetcher.state === "submitting";
  const error = fetcher.data?.error;

  useEffect(() => {
    if (fetcher.data?.success) {
      setAccessToken(fetcher.data.token);
      console.log(fetcher.data.login);
      setUserData(fetcher.data.login, fetcher.data.role);
      navigate("/");
    }
  }, [fetcher.data, setAccessToken, setUserData, navigate]);

  return (
    <PageContainer>
      <LoginCard>
        <Title>Witaj</Title>

        <fetcher.Form method="post">
          {error && <ErrorMessage>{error}</ErrorMessage>}

          <StyledInput
            type="text"
            name="loginEmail"
            placeholder="Login/Email"
            required
          />

          <StyledInput
            type="password"
            name="password"
            placeholder="Password"
            required
          />

          <ButtonGroup>
            <CancelButton
              type="button"
              onClick={() => {
                navigate("/");
              }}
            >
              Anuluj
            </CancelButton>

            <SubmitButton type="submit" disabled={isSubmitting}>
              {isSubmitting ? "Logowanie..." : "Zaloguj"}
            </SubmitButton>
          </ButtonGroup>
        </fetcher.Form>

        <Divider />

        <CreateAccountButton onClick={() => navigate("/register")}>
          Stwórz konto
        </CreateAccountButton>
      </LoginCard>
    </PageContainer>
  );
}
