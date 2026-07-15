document.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll("[data-confirm]").forEach((button) => {
        button.addEventListener("click", (event) => {
            const message = button.getAttribute("data-confirm") || "Are you sure?";
            if (!window.confirm(message)) {
                event.preventDefault();
            }
        });
    });

    document.querySelectorAll(".table-filter").forEach((input) => {
        const targetSelector = input.getAttribute("data-target");
        const table = document.querySelector(targetSelector);
        if (!table) return;

        input.addEventListener("input", () => {
            const query = input.value.trim().toLowerCase();
            table.querySelectorAll("tbody tr").forEach((row) => {
                const text = row.textContent.toLowerCase();
                row.classList.toggle("d-none", query && !text.includes(query));
            });
        });
    });
});
