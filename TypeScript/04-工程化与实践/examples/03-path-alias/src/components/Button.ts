/**
 * 模拟一个按钮组件类
 */
export class Button {
  constructor(public label: string) {}

  click(): void {
    console.log(`按钮 "${this.label}" 被点击了`);
  }
}
