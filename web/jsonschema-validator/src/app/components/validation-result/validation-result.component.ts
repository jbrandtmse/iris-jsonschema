import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-validation-result',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './validation-result.component.html',
  styleUrl: './validation-result.component.scss'
})
export class ValidationResultComponent {
  @Input() hasResults = false;
}
