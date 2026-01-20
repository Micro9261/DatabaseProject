import { useEffect } from "react";
import { useFetcher, useNavigate } from "react-router-dom";
import styled from "styled-components";
import { useAuth } from "../Context/AuthContext";

const PageContainer = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  background-color: #f4f6f8;
  font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
`;

const RegisterCard = styled.div`
  background: white;
  padding: 40px;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  width: 100%;
  max-width: 500px;
`;

const Title = styled.h2`
  margin-bottom: 24px;
  color: #333;
  text-align: center;
`;

const FormGrid = styled.div`
  display: flex;
  flex-direction: column;
  gap: 16px;
`;

const Row = styled.div`
  display: flex;
  gap: 16px;
  width: 100%;
`;

const FormGroup = styled.div`
  display: flex;
  flex-direction: column;
  flex: 1;
`;

const Label = styled.label`
  font-size: 14px;
  color: #555;
  margin-bottom: 6px;
  font-weight: 500;
`;

const StyledInput = styled.input`
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  box-sizing: border-box;
  font-size: 16px;

  &:focus {
    border-color: #007bff;
    outline: none;
  }
`;

const StyledSelect = styled.select`
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  box-sizing: border-box;
  font-size: 16px;
  background-color: white;

  &:focus {
    border-color: #007bff;
    outline: none;
  }
`;

const Divider = styled.hr`
  border: 0;
  border-top: 1px solid #eee;
  margin: 24px 0;
`;

const ButtonGroup = styled.div`
  display: flex;
  gap: 16px;
  margin-top: 10px;
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

const CancelButton = styled(Button)`
  background-color: #e2e6ea;
  color: #333;

  &:hover:not(:disabled) {
    background-color: #dbe2e8;
  }
`;

const CreateButton = styled(Button)`
  background-color: #28a745;
  color: white;

  &:hover:not(:disabled) {
    background-color: #218838;
  }
`;

const ErrorMessage = styled.div`
  background-color: #f8d7da;
  color: #721c24;
  padding: 10px;
  border-radius: 4px;
  margin-bottom: 16px;
  text-align: center;
  font-size: 14px;
`;

export async function registerAction({ request }) {
  const formData = await request.formData();

  const name = formData.get("name");
  const surname = formData.get("surname");
  const login = formData.get("login");
  const email = formData.get("email");
  const password = formData.get("password");
  const passwordRepeat = formData.get("passwordRepeat");
  const gender = formData.get("gender");

  if (password !== passwordRepeat) {
    return { error: "Hasła muszą być takie same" };
  }

  const payload = {
    name,
    surname,
    login,
    email,
    password,
    gender,
  };

  try {
    const response = await fetch("http://localhost:3000/api/users/", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      try {
        const errJson = await response.json();
        return { error: errJson.message || "Błąd rejestracji" };
      } catch {
        return { error: "Błąd rejestracji. Status: " + response.status };
      }
    }

    const data = await response.json();
    const backendLogin = data.login;

    try {
      const payload = {
        password,
        login: backendLogin,
      };

      const response = await fetch("http://localhost:3000/api/users/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      const data = await response.json();

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
  } catch (err) {
    console.log(err);
    return { error: "Błąd serwera! Serwer działa?" };
  }
}

export function RegisterPage() {
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
      <RegisterCard>
        <Title>Tworzenie konta</Title>

        <fetcher.Form method="post">
          {error && <ErrorMessage>{error}</ErrorMessage>}

          <FormGrid>
            <Row>
              <FormGroup>
                <Label>Imię</Label>
                <StyledInput name="name" placeholder="Imię" required />
              </FormGroup>
              <FormGroup>
                <Label>Nazwisko</Label>
                <StyledInput name="surname" placeholder="Nazwisko" required />
              </FormGroup>
            </Row>

            <FormGroup>
              <Label>Login</Label>
              <StyledInput name="login" placeholder="login" required />
            </FormGroup>

            <FormGroup>
              <Label>Email</Label>
              <StyledInput name="email" placeholder="email" required />
            </FormGroup>

            <FormGroup>
              <Label>Hasło</Label>
              <StyledInput
                type="password"
                placeholder="hasło"
                name="password"
                required
                minLength={4}
              />
            </FormGroup>

            <FormGroup>
              <Label>Powtórz hasło</Label>
              <StyledInput
                type="password"
                placeholder="hasło"
                name="passwordRepeat"
                required
                minLength={4}
              />
            </FormGroup>

            <FormGroup>
              <Label>Płeć</Label>
              <StyledSelect name="gender" defaultValue={""} required>
                <option value={""} disabled>
                  Wybierz
                </option>
                <option value={"male"}>Mężczyzna</option>
                <option value={"female"}>Kobieta</option>
                <option value="other">Inna</option>
              </StyledSelect>
            </FormGroup>
          </FormGrid>

          <Divider />

          <ButtonGroup>
            <CancelButton
              type="button"
              onClick={() => navigate("/")}
              disabled={isSubmitting}
            >
              Anuluj
            </CancelButton>

            <CreateButton type="submit" disabled={isSubmitting}>
              {isSubmitting ? "Tworzenie..." : "Utwórz"}
            </CreateButton>
          </ButtonGroup>
        </fetcher.Form>
      </RegisterCard>
    </PageContainer>
  );
}
