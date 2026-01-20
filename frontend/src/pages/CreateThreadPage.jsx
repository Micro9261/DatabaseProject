import React, { useState, useEffect } from "react";
import styled from "styled-components";
import TextareaAutosize from "react-textarea-autosize";
import { useNavigate, useOutletContext } from "react-router-dom";
import { useAuth } from "../Context/AuthContext"; // Adjust path as needed
import { useFetchWithAuth } from "../utils/fetchData"; // Adjust path as needed

const Container = styled.div`
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding: 40px;
  max-width: 800px;
  margin: 0 auto;
`;

const TitleInput = styled.input`
  font-size: 2rem;
  font-weight: bold;
  padding: 10px;
  border: 1px solid #ccc;
  border-radius: 5px;
  outline: none;
  &:focus {
    border-color: green;
  }
`;

const ContentTextArea = styled(TextareaAutosize)`
  font-size: 1.1rem;
  padding: 10px;
  min-height: 200px;
  border: 1px solid #ccc;
  border-radius: 5px;
  resize: none;
  outline: none;
  &:focus {
    border-color: green;
  }
`;

const ButtonGroup = styled.div`
  display: flex;
  gap: 15px;
  justify-content: flex-end;
`;

const Button = styled.button`
  padding: 10px 25px;
  border-radius: 5px;
  border: none;
  cursor: pointer;
  font-weight: bold;
  transition: opacity 0.2s;

  &:hover {
    opacity: 0.8;
  }
`;

const CreateButton = styled(Button)`
  background-color: green;
  color: white;
`;

const CancelButton = styled(Button)`
  background-color: #ccc;
  color: black;
`;

export function CreateThreadPage() {
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const { refreshSummary } = useOutletContext();

  const { getUserData } = useAuth();
  const fetchWithAuth = useFetchWithAuth();
  const navigate = useNavigate();

  const userData = getUserData();

  useEffect(() => {
    if (!userData.login || !userData.role) {
      navigate("/login");
    }
  }, [userData, navigate]);

  const handleCreate = async () => {
    if (!title.trim() || !content.trim()) {
      alert("Please fill in both title and content.");
      return;
    }

    setIsSubmitting(true);
    try {
      const response = await fetchWithAuth("/Threads", {
        method: "POST",
        body: JSON.stringify({ title, content }),
      });

      if (response.ok) {
        const data = await response.json();
        refreshSummary();
        navigate(`/Threads/${data.id}`);
      } else {
        const errorData = await response.json().catch(() => ({}));
        alert(
          `Failed to create thread: ${errorData.message || "Server error"}`,
        );
      }
    } catch (error) {
      console.error("Error creating project:", error);
      alert("Network error. Please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleCancel = () => {
    navigate(-1);
  };

  return (
    <Container>
      <h1>Nowy wątek</h1>

      <TitleInput
        placeholder="Tytuł wątku"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
      />

      <ContentTextArea
        placeholder="Opisz swój problem / potrzebę"
        value={content}
        onChange={(e) => setContent(e.target.value)}
      />

      <ButtonGroup>
        <CancelButton onClick={handleCancel}>Cancel</CancelButton>
        <CreateButton onClick={handleCreate} disabled={isSubmitting}>
          {isSubmitting ? "Tworzenie..." : "Upublikuj"}
        </CreateButton>
      </ButtonGroup>
    </Container>
  );
}
