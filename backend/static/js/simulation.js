// =============================
// WUMPUS WORLD SIMULATION
// =============================

let simulationSteps = [];
let currentStep = 0;
let timer = null;

// -----------------------------
// Load Simulation from Flask API
// -----------------------------
async function loadSimulation(sessionId = 1) {

    try {

        const response = await fetch(`/api/simulation/${sessionId}`);

        if (!response.ok) {
            throw new Error("Unable to load simulation data.");
        }

        simulationSteps = await response.json();

        currentStep = 0;

        initializeWorld();

    } catch (error) {

        console.error(error);

        alert("Failed to load simulation from database.");

    }

}

// -----------------------------
// Draw Static World
// -----------------------------
function initializeWorld() {

    document.querySelectorAll(".grid-cell").forEach(cell => {

        cell.classList.remove(
            "agent",
            "visited",
            "pit",
            "gold",
            "wumpus",
            "exit",
            "agent-animation"
        );

        cell.querySelector(".cell-content").innerHTML = "";

    });

    // Static objects
    setIcon(1, 1, "👹", "wumpus");
    setIcon(0, 2, "🕳️", "pit");
    setIcon(1, 2, "💰", "gold");
    setIcon(3, 3, "🚪", "exit");

    if (simulationSteps.length > 0) {
        renderStep();
    }

}

// -----------------------------
// Helper
// -----------------------------
function setIcon(row, col, icon, className) {

    const cell = document.getElementById(`cell-${row}-${col}`);

    if (!cell) return;

    cell.classList.add(className);

    cell.querySelector(".cell-content").innerHTML = icon;

}

// -----------------------------
// Render Current Step
// -----------------------------
function renderStep() {

    if (simulationSteps.length === 0) return;

    document.querySelectorAll(".grid-cell").forEach(cell => {

        cell.classList.remove(
            "agent",
            "agent-animation"
        );

    });

    const step = simulationSteps[currentStep];

    const cell = document.getElementById(
        `cell-${step.row}-${step.col}`
    );

    if (!cell) return;

    cell.classList.add("agent");
    cell.classList.add("visited");
    cell.classList.add("agent-animation");

    cell.querySelector(".cell-content").innerHTML = "😀";

    document.getElementById("current-step").innerText =
        step.step ?? currentStep + 1;

    document.getElementById("current-score").innerText =
        step.score;

    document.getElementById("current-direction").innerText =
        step.direction;

    document.getElementById("game-status").innerText =
        "Running";

    document.getElementById("breeze").innerText =
        step.perceptions.includes("Breeze") ? "Yes" : "No";

    document.getElementById("stench").innerText =
        step.perceptions.includes("Stench") ? "Yes" : "No";

    document.getElementById("glitter").innerText =
        step.perceptions.includes("Glitter") ? "Yes" : "No";

}

// -----------------------------
// Next
// -----------------------------
document.getElementById("nextBtn").onclick = () => {

    if (currentStep < simulationSteps.length - 1) {

        currentStep++;

        renderStep();

    }

};

// -----------------------------
// Previous
// -----------------------------
document.getElementById("previousBtn").onclick = () => {

    if (currentStep > 0) {

        currentStep--;

        renderStep();

    }

};

// -----------------------------
// Reset
// -----------------------------
document.getElementById("resetBtn").onclick = () => {

    clearInterval(timer);

    currentStep = 0;

    initializeWorld();

};

// -----------------------------
// Pause
// -----------------------------
document.getElementById("pauseBtn").onclick = () => {

    clearInterval(timer);

};

// -----------------------------
// Auto Play
// -----------------------------
document.getElementById("startBtn").onclick = () => {

    clearInterval(timer);

    timer = setInterval(() => {

        if (currentStep < simulationSteps.length - 1) {

            currentStep++;

            renderStep();

        } else {

            clearInterval(timer);

            document.getElementById("game-status").innerText =
                "Completed";

        }

    }, 1000);

};

// -----------------------------
// Start
// -----------------------------
window.onload = () => {

    loadSimulation();

};